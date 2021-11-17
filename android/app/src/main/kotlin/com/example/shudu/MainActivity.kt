package com.example.shudu

import android.content.Context
import android.graphics.Color

import android.os.Build
import android.os.Bundle

import io.flutter.embedding.android.FlutterActivity
// import com.example.hot_fix.HotFixActivity


class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
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
//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
// //            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS or WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
// //            window.getDecorView().setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
// //            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
// //            )
// //             or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
// //            window.decorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN )
//             window.statusBarColor = Color.TRANSPARENT
// //            window.setNavigationBarColor(Color.TRANSPARENT)
//         }
    }

}