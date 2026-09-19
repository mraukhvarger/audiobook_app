package com.playerbook.player_book

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    private val channelName = "com.playerbook/audio_source"
    private val mediaProbeChannelName = "com.playerbook/media_probe"
    private val pickFolderRequestCode = 4201
    private var pendingPickResult: MethodChannel.Result? = null
    private lateinit var audioSource: SafAudioSource
    private lateinit var mediaProbe: MediaProbe

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        audioSource = SafAudioSource(applicationContext)
        mediaProbe = MediaProbe(applicationContext)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickFolder" -> pickFolder(result)
                    "folderName" -> respond(result) {
                        audioSource.folderName(call.requireArgument("uri"))
                    }

                    "listFiles" -> respond(result) {
                        audioSource.listFiles(call.requireArgument("uri"))
                    }

                    "duration" -> respond(result) {
                        audioSource.probeDuration(call.requireArgument("uri"))
                    }

                    "metadata" -> respond(result) {
                        audioSource.readMetadata(call.requireArgument("uri"))
                    }

                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, mediaProbeChannelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "duration" -> respond(result) {
                        mediaProbe.duration(
                            call.requireArgument("uri"),
                            call.headers(),
                        )
                    }

                    "metadata" -> respond(result) {
                        mediaProbe.metadata(
                            call.requireArgument("uri"),
                            call.headers(),
                        )
                    }

                    else -> result.notImplemented()
                }
            }
    }

    private fun MethodCall.headers(): Map<String, String> {
        val raw = argument<Map<String, String>>("headers")
        return raw ?: emptyMap()
    }

    private fun pickFolder(result: MethodChannel.Result) {
        if (pendingPickResult != null) {
            result.error("picker_busy", "Folder picker is already open", null)
            return
        }
        pendingPickResult = result
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            addFlags(
                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                putExtra(DocumentsContract.EXTRA_INITIAL_URI, downloadUri())
            }
        }
        startActivityForResult(intent, pickFolderRequestCode)
    }

    private fun downloadUri(): Uri =
        Uri.parse("content://com.android.externalstorage.documents/document/primary%3ADownload")

    @Suppress("DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != pickFolderRequestCode) return
        val result = pendingPickResult ?: return
        pendingPickResult = null
        val uri: Uri? = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return
        }
        try {
            contentResolver.takePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION
            )
        } catch (error: SecurityException) {
            // Permission is not persistable for this provider; transient access still works.
        }
        result.success(
            mapOf(
                "uri" to uri.toString(),
                "name" to audioSource.folderName(uri.toString()),
            )
        )
    }

    private fun MethodCall.requireArgument(name: String): String {
        return argument<String>(name)
            ?: throw IllegalArgumentException("Missing argument: $name")
    }

    private inline fun respond(result: MethodChannel.Result, block: () -> Any?) {
        try {
            result.success(block())
        } catch (error: Exception) {
            result.error("saf_error", error.message, null)
        }
    }
}
