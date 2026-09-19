package com.playerbook.player_book

import android.content.Context
import android.media.MediaMetadataRetriever
import android.net.Uri
import java.io.File

class MediaProbe(private val context: Context) {

    fun duration(uri: String, headers: Map<String, String>): Long {
        val retriever = MediaMetadataRetriever()
        return try {
            setDataSource(retriever, uri, headers)
            retriever
                .extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
                ?.toLongOrNull()
                ?: 0L
        } catch (error: Exception) {
            0L
        } finally {
            retriever.release()
        }
    }

    fun metadata(uri: String, headers: Map<String, String>): Map<String, Any?>? {
        val retriever = MediaMetadataRetriever()
        return try {
            setDataSource(retriever, uri, headers)
            val title = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE)
            val author = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST)
                ?: retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUMARTIST)
            val coverPath = saveEmbeddedPicture(retriever, uri)
            if (title == null && author == null && coverPath == null) {
                null
            } else {
                mapOf(
                    "title" to title,
                    "author" to author,
                    "coverPath" to coverPath,
                )
            }
        } catch (error: Exception) {
            null
        } finally {
            retriever.release()
        }
    }

    private fun setDataSource(
        retriever: MediaMetadataRetriever,
        uri: String,
        headers: Map<String, String>,
    ) {
        if (headers.isEmpty()) {
            val parsed = Uri.parse(uri)
            if (parsed.scheme == "content") {
                retriever.setDataSource(context, parsed)
            } else {
                retriever.setDataSource(uri)
            }
        } else {
            retriever.setDataSource(uri, headers)
        }
    }

    private fun saveEmbeddedPicture(
        retriever: MediaMetadataRetriever,
        uri: String,
    ): String? {
        val bytes = retriever.embeddedPicture ?: return null
        return try {
            val directory = File(context.cacheDir, "covers").apply { mkdirs() }
            val file = File(directory, "cover_${uri.hashCode()}.jpg")
            file.writeBytes(bytes)
            file.absolutePath
        } catch (error: Exception) {
            null
        }
    }
}
