package com.lichaojian.image_picker

import android.os.Bundle
import io.flutter.app.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        MediaPlugin.registerMediaPlugin(this)
    }
}
