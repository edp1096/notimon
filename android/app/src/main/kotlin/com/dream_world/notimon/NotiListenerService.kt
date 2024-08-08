package com.dream_world.notimon

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import android.os.Handler
import android.os.Looper

class NotiListenerService : NotificationListenerService() {
    companion object {
        var channel: MethodChannel? = null
    }

    override fun onListenerConnected() {
        super.onListenerConnected()
        Log.d("MyNotificationListener", "Notification Listener Service Connected")
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()
        Log.d("MyNotificationListener", "onListenerDisconnected()")
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        super.onNotificationPosted(sbn)
        Log.d("MyNotificationListener", "Notification Posted")

        val packageName = sbn.packageName
        val notification = sbn.notification
        val extras = notification.extras

        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString()
        var text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""
        val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString() ?: ""

        if (text.isEmpty() && bigText.isNotEmpty()) {
            text = bigText
        }

        val notificationInfo = mapOf(
            "packageName" to packageName,
            "title" to title,
            "text" to text
        )

        Log.d("MyNotificationListener", "Notification Info: $notificationInfo")

        Handler(Looper.getMainLooper()).post {
            channel?.invokeMethod("onNotificationPosted", notificationInfo)
        }
    }
}
