package com.example.chatext

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import org.chatext.waku.waku_bridge.MobileMessageCallback
import org.chatext.waku.waku_bridge.MobileWakuManager
import org.chatext.waku.waku_bridge.Waku_bridge

class WakuPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var wakuManager: MobileWakuManager? = null
    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = MethodChannel(binding.binaryMessenger, "chatext/waku")
        methodChannel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "chatext/waku/events")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }
            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "createNode" -> handleCreateNode(call, result)
            "send" -> handleSend(call, result)
            "subscribe" -> handleSubscribe(call, result)
            "stop" -> handleStop(result)
            else -> result.notImplemented()
        }
    }

    private fun handleCreateNode(call: MethodCall, result: MethodChannel.Result) {
        try {
            val host = call.argument<String>("host") ?: "0.0.0.0"
            val port = (call.argument<Int>("port") ?: 60000).toLong()
            val bootnodes = call.argument<List<String>>("bootnodes") ?: emptyList()

            wakuManager = Waku_bridge.createNode(host, port, bootnodes.joinToString(","))
            wakuManager?.setCallback(object : MobileMessageCallback {
                override fun onMessage(topic: String, payload: ByteArray, timestamp: Long) {
                    mainHandler.post {
                        eventSink?.success(mapOf(
                            "topic" to topic,
                            "payload" to payload,
                            "timestamp" to timestamp
                        ))
                    }
                }
            })

            result.success(null)
        } catch (e: Exception) {
            result.error("CREATE_NODE_ERROR", e.message, e.stackTraceToString())
        }
    }

    private fun handleSend(call: MethodCall, result: MethodChannel.Result) {
        try {
            val topic = call.argument<String>("topic")!!
            val data = call.argument<ByteArray>("data")!!

            wakuManager?.send(topic, data)
            result.success(null)
        } catch (e: Exception) {
            result.error("SEND_ERROR", e.message, e.stackTraceToString())
        }
    }

    private fun handleSubscribe(call: MethodCall, result: MethodChannel.Result) {
        try {
            val topic = call.argument<String>("topic")!!

            wakuManager?.subscribe(topic)
            result.success(null)
        } catch (e: Exception) {
            result.error("SUBSCRIBE_ERROR", e.message, e.stackTraceToString())
        }
    }

    private fun handleStop(result: MethodChannel.Result) {
        try {
            wakuManager?.stop()
            wakuManager = null
            result.success(null)
        } catch (e: Exception) {
            result.error("STOP_ERROR", e.message, e.stackTraceToString())
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }
}
