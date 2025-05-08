package com.foodlab.pens

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import android.app.AlertDialog
import android.content.Intent
import android.net.Uri
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }
    
    private val CHANNEL_ID = "fcm_fallback_notification_channel"

   private fun createNotificationChannel() {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
         val name = "Miscellaneous"
         val descriptionText = "General notifications"
         val importance = NotificationManager.IMPORTANCE_HIGH
         val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
               description = descriptionText
               enableLights(true)
               enableVibration(true)
         }

         val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
         notificationManager.createNotificationChannel(channel)
      }
   }
}
