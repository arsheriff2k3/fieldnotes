package com.example.fieldnotes_flutter

import android.app.NotificationManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "fieldnote/notifications")
            .setMethodCallHandler { call, result ->
                if (call.method == "clear") {
                    val id = call.argument<Number>("notificationId")?.toInt()
                    if (id == null) {
                        result.error("invalid_id", "Notification ID required", null)
                    } else {
                        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                        manager.activeNotifications.filter { it.tag == "fieldnote-$id" }
                            .forEach { manager.cancel(it.tag, it.id) }
                        result.success(null)
                    }
                } else {
                    result.notImplemented()
                }
            }
    }
}
