package com.dream_world.notimon

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.plugin.common.MethodChannel
import android.os.Handler
import android.os.Looper

class MyNotificationListenerService : NotificationListenerService() {
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

        val notiTag = extras.getString(Notification.EXTRA_NOTIFICATION_TAG) ?: ""
        val convTitle = extras.getString(Notification.EXTRA_CONVERSATION_TITLE) ?: ""

        // val title = extras.getString(Notification.EXTRA_TITLE) ?: ""
        val title = extras.getCharSequence(Notification.EXTRA_TITLE)?.toString()
        val bigTitle = extras.getString(Notification.EXTRA_TITLE_BIG) ?: ""
        var text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""
        val bigText = extras.getCharSequence(Notification.EXTRA_BIG_TEXT)?.toString() ?: ""
        val summary = extras.getString(Notification.EXTRA_SUMMARY_TEXT) ?: ""
        val subtext = extras.getString(Notification.EXTRA_SUB_TEXT) ?: ""
        val veritext = extras.getString(Notification.EXTRA_VERIFICATION_TEXT) ?: ""
        val infotext = extras.getString(Notification.EXTRA_INFO_TEXT) ?: ""

        if (text.isEmpty() && bigText.isNotEmpty()) {
            text = bigText
        }

        val notificationInfo = mapOf(
            "packageName" to packageName,
            "notiTag" to notiTag,
            "convTitle" to convTitle,
            "title" to title,
            "bigTitle" to bigTitle,
            "text" to text,
            "bigText" to bigText,
            "summary" to summary,
            "subtext" to subtext,
            "veritext" to veritext,
            "infotext" to infotext
        )

        Log.d("MyNotificationListener", "Notification Info: $notificationInfo")

        Handler(Looper.getMainLooper()).post {
            channel?.invokeMethod("onNotificationPosted", notificationInfo)
        }
    }
}
