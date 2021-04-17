package com.example.bangs

import android.app.Activity
import android.os.Build
import android.util.Log
import android.view.Choreographer
import android.view.Display
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterJNI
import io.flutter.embedding.engine.FlutterJNI.AsyncWaitForVsyncDelegate
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlin.math.round

/** BangsPlugin */
class BangsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    companion object {
        private const val TAG = "BangsPlugin"
    }

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "bangs")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${Build.VERSION.RELEASE}")
            }
            "safePadding" -> {
                val padding = hasNotchInScreen(activity)
                result.success(padding)
            }
            "bottomHeight" -> {
                val height = getBottomHeight(activity)
                result.success(height)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun getBottomHeight(activity: Activity?): Int {
        val height = activity?.resources?.getDimensionPixelSize(
                activity.resources.getIdentifier("navigation_bar_height", "dimen", "android"))

        if (height != null) {
            return height
        }
        return 0;
    }

    private fun hasNotchInScreen(activity: Activity?): Map<String, Double> {
        if (activity == null) {
            return mapOf()
        }
        // android  P 以上有标准 API 来判断是否有刘海屏
        val decorView = activity.window.decorView
        val decorViewWidth = decorView.width
        val decorViewHeight = decorView.height
        Log.i(TAG, "decorView Height  $decorViewHeight")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val windowInsets = decorView.rootWindowInsets
            if (windowInsets != null) {
                val displayCutout = windowInsets.displayCutout;
                if (displayCutout != null) {
                    val left = displayCutout.safeInsetLeft
                    val top = displayCutout.safeInsetTop;
                    val right = displayCutout.safeInsetRight
                    val bottom = displayCutout.safeInsetBottom;
                    Log.i(TAG, displayCutout.boundingRects.toString())
                    return mapOf("left" to left.toDouble(), "top" to top.toDouble(),
                            "right" to right.toDouble(), "bottom" to bottom.toDouble(),
                            "height" to decorViewHeight.toDouble(), "width" to decorViewWidth.toDouble())
                }
            }
        }
        return mapOf("height" to decorViewHeight.toDouble(), "width" to decorViewWidth.toDouble())
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        val _activity = binding.activity
 //       var modes: Array<Display.Mode>? = null
 //       if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
 //           modes = _activity.display?.supportedModes
 //       } else {
 //           if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//                modes = _activity.windowManager.defaultDisplay.supportedModes
 //           }
 //       }
//
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
//            modes?.last()?.apply {
//                FlutterJNI.setAsyncWaitForVsyncDelegate {
//                    Choreographer.getInstance()
//                            .postFrameCallback { frameTimeNanos ->
//                                val refreshPeriodNanos = (1000000000.0 / refreshRate).toLong()
//                                FlutterJNI.nativeOnVsync(
//                                        frameTimeNanos, frameTimeNanos + refreshPeriodNanos, it)
//                            }
//                }
//                在 @MainActivity 设置
//                FlutterJNI.setRefreshRateFPS(refreshRate)
//            }
//        }
        activity = _activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }
}
