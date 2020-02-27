package com.lichaojian.image_picker

import android.content.ContentResolver
import android.provider.MediaStore
import android.util.Log
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * @Desc: media plugin
 * @Author: lichaojian
 * @Date: 2020/2/27.
 * @Email: lichaojian@yy.com
 * @YY: 909042302
 */
class MediaPlugin(flutterActivity: FlutterActivity) : MethodChannel.MethodCallHandler {
    companion object {
        private const val TAG = "MediaPlugin"
        private const val CHANNEL = "com.lichaojian.image_picker/Media"
        private const val GET_IMAGES = "getImages"

        fun registerMediaPlugin(flutterActivity: FlutterActivity) {
            val methodChannel = MethodChannel(flutterActivity.flutterView, CHANNEL)
            methodChannel.setMethodCallHandler(MediaPlugin(flutterActivity))
        }
    }

    private var mFlutterActivity = flutterActivity
    private val mImageList  = ArrayList<String>(6000)

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            GET_IMAGES -> {
                getImages(result)
            }
            else -> {
                Log.i(TAG, "can't find the method ${methodCall.method}")
                result.notImplemented()
            }
        }
    }

    private fun getImages(result: MethodChannel.Result) {
        val imageUri = MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        val contentResolver: ContentResolver = mFlutterActivity.contentResolver
        val projection = arrayOf(
            MediaStore.Images.ImageColumns.DATA, MediaStore.Images.ImageColumns.DISPLAY_NAME,
            MediaStore.Images.ImageColumns.SIZE, MediaStore.Images.ImageColumns.DATE_ADDED
        )
        val cursor = contentResolver.query(imageUri, projection, null, null, MediaStore.Images.Media.DATE_ADDED + " desc")
        if (cursor == null) {
            result.error("UNAVAILABLE", "get photos error.", null)
            return
        } else {
            while (cursor.moveToNext()) {
                val path = cursor.getString(cursor.getColumnIndex(MediaStore.Images.ImageColumns.DATA))
                mImageList.add(path)
            }
            cursor.close()
            result.success(mImageList)
        }
    }
}