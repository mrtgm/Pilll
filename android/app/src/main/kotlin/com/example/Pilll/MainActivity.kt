package com.mizuki.Ohashi.Pilll

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState);
        Log.d("android message: ", "onCreate")
    }

    override fun onStart() {
        super.onStart()
        Log.d("android message: ", "onStart")
        createNotificationChannel();
        register()
    }
    private fun createNotificationChannel() {
        // Create the NotificationChannel, but only on API 26+ because
        // the NotificationChannel class is new and not in the support library
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_DEFAULT
            val channel = NotificationChannel("PILL_REMINDER", "method.channel.MizukiOhashi.Pilll", importance).apply {
                description = "method.channel.MizukiOhashi.Pilll.description"
            }
            // Register the channel with the system
            val notificationManager: NotificationManager =
                    getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
    private fun register() {
//        this.registerReceiver(BroadCastActionReceiver(), IntentFilter("PILL_REMINDER"))
        this.registerReceiver(broadcastReceiver, IntentFilter("PILL_REMINDER"))
    }

    var broadcastReceiver: BroadcastReceiver = object: BroadcastReceiver() {
        override fun onReceive(p0: Context?, p1: Intent?) {
            Log.d("android message:", "BroadcastReceiver.onReceive")
            callRecordPill()
        }
    }

    private fun methodChannel(): MethodChannel {
        val flutterEngine = FlutterEngine(this)
        flutterEngine
                .dartExecutor
                .executeDartEntrypoint(
                        DartExecutor.DartEntrypoint.createDefault()
                )
        return MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "method.channel.MizukiOhashi.Pilll")
    }
    private fun callRecordPill() {
        methodChannel().invokeMethod("recordPill", "")
    }
}
