package com.example.shudu

import android.os.Build
import android.util.Log
import android.view.Choreographer
import android.view.WindowManager
import io.flutter.FlutterInjector
import io.flutter.app.FlutterApplication
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.FlutterJNI
import io.flutter.embedding.engine.dart.DartExecutor

class MyApplication : FlutterApplication() {
    override fun onCreate() {
        val loader = FlutterInjector.instance().flutterLoader()
        val jni = FlutterJNI()

        loader.startInitialization(this)
        loader.ensureInitializationComplete(this, null)
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//            val windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
//            val modes = windowManager.defaultDisplay.supportedModes!!
//            modes.sortBy {
//                it.refreshRate
//            }
//
//            modes.first()?.apply {
//                val rate = refreshRate
//                FlutterJNI.setRefreshRateFPS(refreshRate)
//                Log.i("FlutterActivity", "done ....")
//                FlutterJNI.setAsyncWaitForVsyncDelegate {
//                    Choreographer.getInstance()
//                            .postFrameCallback { frameTimeNanos ->
//                                val refreshPeriodNanos = (1000000000.0 / rate).toLong()
//                                FlutterJNI.nativeOnVsync(
//                                        frameTimeNanos, frameTimeNanos  + refreshPeriodNanos, it)
//                            }
//                }
//            }
//        }
        jni.attachToNative(false)

        val f = FlutterEngine(this, loader, jni,null, false)
        f.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
        )
        FlutterEngineCache.getInstance().put("myEngine", f)
        super.onCreate()
    }
}