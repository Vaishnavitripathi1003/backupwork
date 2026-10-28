package com.daksh.ml

import android.content.Context
import android.security.keystore.KeyProperties
import java.io.InputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder
import javax.crypto.Cipher
import javax.crypto.spec.SecretKeySpec

object KeyManager {
    fun decryptModel(context: Context, passphrase: String): ByteBuffer {

        val key = SecretKeySpec(passphrase.toByteArray(), ALGORITHM)

        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.DECRYPT_MODE, key)

        val encryptedBytes = context.assets
            .open("xa.sdk")
            .use { it.readBytes() }

        val modelBytes = cipher.doFinal(encryptedBytes)

        return ByteBuffer
            .allocateDirect(modelBytes.size)
            .order(ByteOrder.nativeOrder())
            .apply {
                put(modelBytes)
                rewind()
            }
    }

    fun decryptModel2(context: Context, passphrase: String): ByteBuffer {
        val key = SecretKeySpec(passphrase.toByteArray(), ALGORITHM)
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.DECRYPT_MODE, key)

        val inputStream: InputStream = context.assets.open("ir.sdk")
        val size: Int = inputStream.available()
        val largeFile = ByteArray(size)
        inputStream.read(largeFile)

        val bytes = cipher.doFinal(largeFile)

        val buffer = ByteBuffer.allocateDirect(size).order(ByteOrder.nativeOrder())
        buffer.order(ByteOrder.nativeOrder())
        buffer.put(bytes)
        buffer.rewind()

        return buffer
    }

    fun decryptModel3(context: Context, passphrase: String): ByteBuffer {
        val key = SecretKeySpec(passphrase.toByteArray(), ALGORITHM)
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.DECRYPT_MODE, key)

        val inputStream: InputStream = context.assets.open("fq.sdk")
        val size: Int = inputStream.available()
        val largeFile = ByteArray(size)
        inputStream.read(largeFile)

        val bytes = cipher.doFinal(largeFile)

        val buffer = ByteBuffer.allocateDirect(size).order(ByteOrder.nativeOrder())
        buffer.order(ByteOrder.nativeOrder())
        buffer.put(bytes)
        buffer.rewind()

        return buffer
    }

    private const val ALGORITHM = KeyProperties.KEY_ALGORITHM_AES
    private const val BLOCK_MODE = KeyProperties.BLOCK_MODE_ECB
    private const val PADDING = KeyProperties.ENCRYPTION_PADDING_PKCS7
    private const val TRANSFORMATION = "$ALGORITHM/$BLOCK_MODE/$PADDING"

}