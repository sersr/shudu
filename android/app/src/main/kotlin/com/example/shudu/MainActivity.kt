package com.example.shudu

import android.content.Context
import android.graphics.Color
import android.hardware.display.DisplayManager
import android.hardware.display.DisplayManager.DisplayListener
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.Choreographer
import android.view.Surface
import android.view.SurfaceHolder
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterSurfaceView
import io.flutter.embedding.engine.FlutterJNI


class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val modes = activity.windowManager.defaultDisplay.supportedModes!!

            modes.sortBy {
                it.refreshRate
            }

            modes.last()?.apply {
                val at = window.attributes
                at.preferredDisplayModeId = modeId
                window.attributes = at

            }

        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
//            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS or WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
//            window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
//            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
//            )
//             or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
//            window.decorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN )
            window.statusBarColor = Color.TRANSPARENT
//            window.setNavigationBarColor(Color.TRANSPARENT)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val displayManager = getSystemService(Context.DISPLAY_SERVICE) as DisplayManager

            val listener = object : DisplayListener {
                override fun onDisplayAdded(i: Int) {}
                override fun onDisplayRemoved(i: Int) {}
                override fun onDisplayChanged(i: Int) {
                    val display = displayManager.getDisplay(i)
                    Log.i("displayChanged", "${display.refreshRate}, ${display.mode}")
//                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
//                        val modes = activity.windowManager.defaultDisplay.supportedModes!!
//
//                        modes.sortBy {
//                            it.refreshRate
//                        }
//
//                        modes.last()?.apply {
//
//                            val at = window.attributes
//                            at.preferredDisplayModeId = modeId
//                            window.attributes = at
//
//                        }
//
//                    }
                }
            }

            displayManager.registerDisplayListener(listener, handler)
        }

    }

//    override fun onResume() {
//        super.onResume()
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
//            val modes = activity.windowManager.defaultDisplay.supportedModes!!
//
//            modes.sortBy {
//                it.refreshRate
//            }
//
//            modes.last()?.apply {
//                val at = window.attributes
//                at.preferredDisplayModeId = modeId
//                window.attributes = at
//
//            }
//
//        }
//    }

    var handler = Handler(Looper.getMainLooper())
    private var s = object : SurfaceHolder.Callback {
        override fun surfaceCreated(holder: SurfaceHolder) {

//            Log.w("displayChanged", "created....")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
//                val modes = activity.windowManager.defaultDisplay.supportedModes!!
//
//                modes.sortBy {
//                    it.refreshRate
//                }
//
//                modes.last()?.apply {
//                    val at = window.attributes
//                    at.preferredDisplayModeId = modeId
//                    window.attributes = at
//                    handler.post {
//                        holder.surface.setFrameRate(
//                            90f,
//                            Surface.FRAME_RATE_COMPATIBILITY_FIXED_SOURCE
//                        )
//                        Log.w("displayChanged", "set....")
//                    }
//                }
//                flutterView.holder.surface.setFrameRate(
//                    90f,
//                    Surface.FRAME_RATE_COMPATIBILITY_DEFAULT
//                )
            }
        }

        override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
//                  val modes = activity.windowManager.defaultDisplay.supportedModes!!
//
//             modes.sortBy {
//                 it.refreshRate
//             }

//             modes.last()?.apply {
//                 val at = window.attributes
//                 at.preferredDisplayModeId = modeId
//                 window.attributes = at
                Log.w("displayChanged", "surfaceChanged....")
                // holder.surface.setFrameRate(90f, Surface.FRAME_RATE_COMPATIBILITY_DEFAULT)
//             }
            }
        }

        override fun surfaceDestroyed(holder: SurfaceHolder) {
            Log.w("displayChanged", "surfaceDestroyed....")
        }

    }
    lateinit var flutterView: FlutterSurfaceView;
    override fun onFlutterSurfaceViewCreated(flutterSurfaceView: FlutterSurfaceView) {
        super.onFlutterSurfaceViewCreated(flutterSurfaceView)
        flutterView = flutterSurfaceView
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            flutterSurfaceView.holder.addCallback(s)
        }
    }

    //  override fun getCachedEngineId(): String? {
    //      return "myEngine"
    //  }

}