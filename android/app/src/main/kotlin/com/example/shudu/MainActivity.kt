package com.example.shudu

import android.os.*
import android.util.Log
import android.view.Display
import android.view.Surface.FRAME_RATE_COMPATIBILITY_FIXED_SOURCE
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterSurfaceView
import io.flutter.embedding.engine.FlutterJNI

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.LOLLIPOP) {
            window.statusBarColor = android.graphics.Color.TRANSPARENT
        }
    }
    // companion object {
    //     private const val TAG = "MainActivity"
    // }


//     override fun onCreate(savedInstanceState: Bundle?) {

//         var modes: Array<Display.Mode>? = null
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
//             modes = activity.display?.supportedModes
//         } else {
//             if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//                 modes = activity.windowManager.defaultDisplay.supportedModes
//                 modes?.sortBy {
//                     it.refreshRate
//                 }
//             }
//         }
//         if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN_MR1) {
//             val manager = (getSystemService(DISPLAY_SERVICE) as DisplayManager)

//             val listen = object : DisplayManager.DisplayListener {
//                 override fun onDisplayAdded(displayId: Int) {
//                     val dis = manager.getDisplay(displayId)
//                     Log.i(TAG, "add $dis")
//                 }

//                 override fun onDisplayChanged(displayId: Int) {
//                     val dis = manager.getDisplay(displayId)
//                     Log.i(TAG, "changed $dis")
//                 }

//                 override fun onDisplayRemoved(displayId: Int) {
//                     val dis = manager.getDisplay(displayId)
//                     Log.i(TAG, "remove $dis")
//                 }
//             }
//             manager.registerDisplayListener(listen, Handler(Looper.getMainLooper()))

//         }

//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//             modes?.last()?.apply {
//                 activity.window.let {
//                     val lp = it.attributes
//                     lp.preferredDisplayModeId = modeId
//                     lp.preferredRefreshRate = refreshRate
//                     it.attributes = lp
//                     Log.i(TAG, "my change : $modeId , $refreshRate")
//                 }
//                 FlutterJNI.setRefreshRateFPS(refreshRate)
//             }
//         }
//         super.onCreate(savedInstanceState)

//     }

    override fun onFlutterSurfaceViewCreated(flutterSurfaceView: FlutterSurfaceView) {
        super.onFlutterSurfaceViewCreated(flutterSurfaceView)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val modes = activity.windowManager.defaultDisplay.supportedModes!!
            modes.sortBy {
                it.refreshRate
            }
            modes.last()?.apply {
                //                Log.i("FlutterActivity", "done ....")
                //                FlutterJNI.setAsyncWaitForVsyncDelegate {
                //                    Choreographer.getInstance()
                //                            .postFrameCallback { frameTimeNanos ->
                //                                val refreshPeriodNanos = (1000000000.0 / refreshRate).toLong()
                //                                FlutterJNI.nativeOnVsync(
                //                                        frameTimeNanos, frameTimeNanos + refreshPeriodNanos, it)
                //                            }
                //                }
                // TODO: engine 没有深入研究，是否有必要
                // 只能第一次调用
//                 FlutterJNI.setRefreshRateFPS(refreshRate)
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.R) {
                    Log.i("Main", "my change : $modeId , $refreshRate")
                    flutterSurfaceView.holder.surface.setFrameRate(refreshRate, FRAME_RATE_COMPATIBILITY_FIXED_SOURCE)
                }
            }

        }
    }
}