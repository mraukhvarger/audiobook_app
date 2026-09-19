package com.playerbook.player_book

import android.content.Context
import android.net.Uri
import android.media.MediaMetadataRetriever
import androidx.documentfile.provider.DocumentFile
import java.io.File

class SafAudioSource(private val context: Context) {

    fun listFiles(treeUri: String): List<Map<String, Any?>> {
        val root = DocumentFile.fromTreeUri(context, Uri.parse(treeUri)) ?: return emptyList()
        val result = mutableListOf<Map<String, Any?>>()
        for (document in root.listFiles()) {
            if (!document.isFile) continue
            val name = document.name ?: continue
            result.add(
                mapOf(
                    "uri" to document.uri.toString(),
                    "name" to name,
                    "size" to document.length(),
                )
            )
        }
        return result
    }

    fun folderName(treeUri: String): String? =
        DocumentFile.fromTreeUri(context, Uri.parse(treeUri))?.name

    fun probeDuration(fileUri: String): Long {
        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(context, Uri.parse(fileUri))
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

    fun readMetadata(fileUri: String): Map<String, Any?>? {
        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(context, Uri.parse(fileUri))
            val title = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE)
            val author = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST)
                ?: retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUMARTIST)
            val coverPath = saveEmbeddedPicture(retriever, fileUri)
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

    private fun saveEmbeddedPicture(retriever: MediaMetadataRetriever, fileUri: String): String? {
        val bytes = retriever.embeddedPicture ?: return null
        return try {
            val directory = File(context.cacheDir, "covers").apply { mkdirs() }
            val file = File(directory, "cover_${fileUri.hashCode()}.jpg")
            file.writeBytes(bytes)
            file.absolutePath
        } catch (error: Exception) {
            null
        }
    }
}
