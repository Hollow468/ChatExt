package waku_bridge

import (
	"context"
	"encoding/hex"
	"errors"
	"fmt"
	"log"
	"sync"
	"time"

	"github.com/multiformats/go-multiaddr"
	"github.com/waku-org/go-waku/waku/v2/node"
	"github.com/waku-org/go-waku/waku/v2/protocol"
	"github.com/waku-org/go-waku/waku/v2/protocol/pb"
)

// WakuMessage 消息结构
type WakuMessage struct {
	ContentTopic string
	Payload      []byte
	Timestamp    int64
}

// MessageCallback 消息回调
type MessageCallback func(msg *WakuMessage)

// WakuManager 管理 Waku 节点生命周期
type WakuManager struct {
	node      *node.WakuNode
	ctx       context.Context
	cancel    context.CancelFunc
	mu        sync.Mutex
	callbacks map[string]MessageCallback
}

// NewWakuManager 创建并启动 Waku 节点
func NewWakuManager(host string, port int, bootstrapNodes []string) (*WakuManager, error) {
	if host == "" {
		host = "0.0.0.0"
	}
	if port <= 0 {
		port = 60000
	}

	ctx, cancel := context.WithCancel(context.Background())

	// Parse listen multiaddr
	listenAddr, err := multiaddr.NewMultiaddr(fmt.Sprintf("/ip4/%s/tcp/%d", host, port))
	if err != nil {
		cancel()
		return nil, fmt.Errorf("failed to parse listen address: %w", err)
	}

	opts := []node.WakuNodeOption{
		node.WithHostAddress(nil), // will use default
		node.WithMultiaddress(listenAddr),
		node.WithWakuRelay(),
	}

	wakuNode, err := node.New(opts...)
	if err != nil {
		cancel()
		return nil, fmt.Errorf("failed to create waku node: %w", err)
	}

	err = wakuNode.Start(ctx)
	if err != nil {
		cancel()
		return nil, fmt.Errorf("failed to start waku node: %w", err)
	}

	// 连接 bootstrap 节点
	for _, addr := range bootstrapNodes {
		if addr == "" {
			continue
		}
		err := wakuNode.DialPeer(ctx, addr)
		if err != nil {
			log.Printf("[WakuManager] warning: failed to dial bootstrap node %s: %v", addr, err)
			continue
		}
		log.Printf("[WakuManager] connected to bootstrap node: %s", addr)
	}

	mgr := &WakuManager{
		node:      wakuNode,
		ctx:       ctx,
		cancel:    cancel,
		callbacks: make(map[string]MessageCallback),
	}

	log.Printf("[WakuManager] node started on %s:%d", host, port)
	return mgr, nil
}

// Subscribe 订阅 content topic
func (w *WakuManager) Subscribe(contentTopic string) error {
	if contentTopic == "" {
		return errors.New("content topic cannot be empty")
	}

	w.mu.Lock()
	defer w.mu.Unlock()

	contentFilter := protocol.NewContentFilter("/waku/2/default-waku/proto", contentTopic)
	subs, err := w.node.Relay().Subscribe(w.ctx, contentFilter)
	if err != nil {
		return fmt.Errorf("failed to subscribe to topic %s: %w", contentTopic, err)
	}

	if len(subs) == 0 {
		return fmt.Errorf("no subscription returned for topic %s", contentTopic)
	}

	sub := subs[0]

	// 启动消息接收 goroutine
	go func() {
		for {
			select {
			case <-w.ctx.Done():
				return
			case env, ok := <-sub.Ch:
				if !ok {
					return
				}
				msg := &WakuMessage{
					ContentTopic: contentTopic,
					Payload:      env.Message().Payload,
					Timestamp:    env.Message().GetTimestamp(),
				}
				log.Printf("[WakuManager] received message on topic %s, payload size: %d",
					contentTopic, len(msg.Payload))

				w.mu.Lock()
				cb, exists := w.callbacks[contentTopic]
				w.mu.Unlock()

				if exists && cb != nil {
					go cb(msg)
				}
			}
		}
	}()

	log.Printf("[WakuManager] subscribed to topic: %s", contentTopic)
	return nil
}

// Publish 发布消息到 content topic
func (w *WakuManager) Publish(contentTopic string, payload []byte, timestamp int64) error {
	if contentTopic == "" {
		return errors.New("content topic cannot be empty")
	}

	if timestamp == 0 {
		timestamp = time.Now().Unix()
	}

	msg := &pb.WakuMessage{
		Payload:      payload,
		ContentTopic: contentTopic,
		Timestamp:    &timestamp,
	}

	_, err := w.node.Relay().Publish(w.ctx, msg)
	if err != nil {
		return fmt.Errorf("failed to publish message to topic %s: %w", contentTopic, err)
	}

	log.Printf("[WakuManager] published message to topic %s, payload size: %d, hash: %s",
		contentTopic, len(payload), hex.EncodeToString(payload[:min(len(payload), 8)]))
	return nil
}

// SetCallback 设置消息回调
func (w *WakuManager) SetCallback(contentTopic string, cb MessageCallback) {
	w.mu.Lock()
	defer w.mu.Unlock()
	w.callbacks[contentTopic] = cb
	log.Printf("[WakuManager] callback set for topic: %s", contentTopic)
}

// Stop 停止节点
func (w *WakuManager) Stop() {
	w.mu.Lock()
	defer w.mu.Unlock()

	log.Println("[WakuManager] stopping node...")
	w.cancel()

	if w.node != nil {
		w.node.Stop()
	}

	w.callbacks = make(map[string]MessageCallback)
	log.Println("[WakuManager] node stopped")
}

// min returns the smaller of a or b.
func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
