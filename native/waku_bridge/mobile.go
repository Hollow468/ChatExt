package waku_bridge

import (
	"errors"
	"log"
	"strings"
	"time"
)

// MobileMessageCallback 供 gomobile 导出的回调接口
type MobileMessageCallback interface {
	OnMessage(topic string, payload []byte, timestamp int64)
}

// MobileWakuManager 供 gomobile 导出
type MobileWakuManager struct {
	mgr          *WakuManager
	globalCB     MobileMessageCallback
	pendingTopics []string
}

// CreateNode 创建节点（gomobile 导出）
// bootnodes 以逗号分隔的 bootstrap 节点地址列表
func CreateNode(host string, port int, bootnodes string) (*MobileWakuManager, error) {
	var nodes []string
	if bootnodes != "" {
		for _, n := range strings.Split(bootnodes, ",") {
			n = strings.TrimSpace(n)
			if n != "" {
				nodes = append(nodes, n)
			}
		}
	}

	mgr, err := NewWakuManager(host, port, nodes)
	if err != nil {
		return nil, err
	}

	return &MobileWakuManager{mgr: mgr}, nil
}

// Send 发送消息（gomobile 导出）
func (m *MobileWakuManager) Send(topic string, data []byte) error {
	if m.mgr == nil {
		return errors.New("node not initialized")
	}
	return m.mgr.Publish(topic, data, time.Now().Unix())
}

// Subscribe 订阅（gomobile 导出）
func (m *MobileWakuManager) Subscribe(topic string) error {
	if m.mgr == nil {
		return errors.New("node not initialized")
	}

	// 如果已经设置了全局回调，自动为新 topic 注册回调
	if m.globalCB != nil {
		cb := m.globalCB
		m.mgr.SetCallback(topic, func(msg *WakuMessage) {
			if cb != nil && msg != nil {
				cb.OnMessage(msg.ContentTopic, msg.Payload, msg.Timestamp)
			}
		})
	}

	return m.mgr.Subscribe(topic)
}

// SetCallback 设置全局回调（gomobile 导出）
// 所有 topic 的消息都会通过该回调返回
func (m *MobileWakuManager) SetCallback(cb MobileMessageCallback) {
	if m.mgr == nil {
		log.Println("[MobileWakuManager] warning: node not initialized, callback not set")
		return
	}

	m.globalCB = cb

	// 为所有已订阅的 topic 设置回调
	wrapper := func(msg *WakuMessage) {
		if cb != nil && msg != nil {
			cb.OnMessage(msg.ContentTopic, msg.Payload, msg.Timestamp)
		}
	}

	m.mgr.mu.Lock()
	for topic := range m.mgr.callbacks {
		if topic != "__mobile_global__" {
			m.mgr.callbacks[topic] = wrapper
		}
	}
	m.mgr.mu.Unlock()

	// 注册一个全局 key（方便后续 Subscribe 时引用）
	m.mgr.SetCallback("__mobile_global__", wrapper)
	log.Println("[MobileWakuManager] global callback set")
}

// Stop 停止（gomobile 导出）
func (m *MobileWakuManager) Stop() {
	if m.mgr == nil {
		return
	}
	m.mgr.Stop()
	m.mgr = nil
}
