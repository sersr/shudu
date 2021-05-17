package com.example.shudu

import android.graphics.Color
import android.os.*
import android.util.Log
import android.view.*
import androidx.core.view.ViewCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterSurfaceView
import io.flutter.embedding.engine.FlutterJNI

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {

            // val modes = windowManager.defaultDisplay.supportedModes!!
            // modes.sortBy {
            //     it.refreshRate
            // }

            // modes.last()?.apply {
            //     val at = window.attributes
            //     at.preferredRefreshRate = refreshRate
            //     at.preferredDisplayModeId = modeId
            //     window.attributes = at
//                val rate = refreshRate
//                FlutterJNI.setRefreshRateFPS(refreshRate)
//                Log.i("FlutterActivity", "done ....")
//                FlutterJNI.setAsyncWaitForVsyncDelegate {
//                    Choreographer.getInstance()
//                            .postFrameCallback { frameTimeNanos ->
//                                val refreshPeriodNanos = (1000000000.0 / rate).toLong()
//                                FlutterJNI.nativeOnVsync(
//                                        frameTimeNanos, frameTimeNanos + refreshPeriodNanos, it)
//                            }
//                }
        // }
        super.onCreate(savedInstanceState)
//         modes.last()?.apply {
//             val at = window.attributes
//             at.preferredRefreshRate = refreshRate
//             at.preferredDisplayModeId = modeId
//             window.attributes = at
// //                val rate = refreshRate
// //                FlutterJNI.setRefreshRateFPS(refreshRate)
// //                Log.i("FlutterActivity", "done ....")
// //                FlutterJNI.setAsyncWaitForVsyncDelegate {
// //                    Choreographer.getInstance()
// //                            .postFrameCallback { frameTimeNanos ->
// //                                val refreshPeriodNanos = (1000000000.0 / rate).toLong()
// //                                FlutterJNI.nativeOnVsync(
// //                                        frameTimeNanos, frameTimeNanos + refreshPeriodNanos, it)
// //                            }
// //                }
//         }
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

    }

    override fun onFlutterSurfaceViewCreated(flutterSurfaceView: FlutterSurfaceView) {
        super.onFlutterSurfaceViewCreated(flutterSurfaceView)

        // val modes = windowManager.defaultDisplay.supportedModes!!
        // modes.sortBy {
        //     it.refreshRate
        // }

        // modes.last()?.apply {
        //     val at = window.attributes
        //     at.preferredRefreshRate = refreshRate
        //     at.preferredDisplayModeId = modeId
        //     window.attributes = at
//                val rate = refreshRate
//                FlutterJNI.setRefreshRateFPS(refreshRate)
//                Log.i("FlutterActivity", "done ....")
//                FlutterJNI.setAsyncWaitForVsyncDelegate {
//                    Choreographer.getInstance()
//                            .postFrameCallback { frameTimeNanos ->
//                                val refreshPeriodNanos = (1000000000.0 / rate).toLong()
//                                FlutterJNI.nativeOnVsync(
//                                        frameTimeNanos, frameTimeNanos + refreshPeriodNanos, it)
//                            }
//                }
        // }
    }

//    override fun getCachedEngineId(): String? {
//        val  s= super.getCachedEngineId()
//        Log.i("Hello", "string...$s")
//        return "myEngine"
//    }
}