package com.daksh.daksh.data.remote

import com.google.gson.GsonBuilder
import com.google.gson.annotations.SerializedName
import okhttp3.MultipartBody
import okhttp3.OkHttpClient
import retrofit2.Response
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.Body
import retrofit2.http.Header
import retrofit2.http.Multipart
import retrofit2.http.PATCH
import retrofit2.http.POST
import retrofit2.http.Part
import retrofit2.http.Query
import java.util.concurrent.TimeUnit

data class FingerScanApiResponse(
    val message: String?,
    val status_code: Int?
)

data class FingerDataY(
    @SerializedName("fingerprint_pattern") val pattern: String,
    @SerializedName("ridge_count") val ridgeCount: Int,
    @SerializedName("pattern_code") val patternCode: String
)

data class FingerPrintScan1Request(
    @SerializedName("fingerLeftIndex") val fingerLeftIndex: FingerDataY? = null,
    @SerializedName("fingerLeftLittle") val fingerLeftLittle: FingerDataY? = null,
    @SerializedName("fingerLeftMiddle") val fingerLeftMiddle: FingerDataY? = null,
    @SerializedName("fingerLeftRing") val fingerLeftRing: FingerDataY? = null,
    @SerializedName("fingerLeftThumb") val fingerLeftThumb: FingerDataY? = null,
    @SerializedName("fingerRightIndex") val fingerRightIndex: FingerDataY? = null,
    @SerializedName("fingerRightLittle") val fingerRightLittle: FingerDataY? = null,
    @SerializedName("fingerRightMiddle") val fingerRightMiddle: FingerDataY? = null,
    @SerializedName("fingerRightRing") val fingerRightRing: FingerDataY? = null,
    @SerializedName("fingerRightThumb") val fingerRightThumb: FingerDataY? = null,
    @SerializedName("isSubmitted") val isSubmitted: Boolean = false
)

interface ApiService {
    @Multipart
    @PATCH("fingerprintscanImage")
    suspend fun fingerprintscanImage(
        @Header("Authorization") auth: String,
        @Query("userData_id") userDataId: String,
        @Part leftThumb: MultipartBody.Part?,
        @Part leftIndex: MultipartBody.Part?,
        @Part leftMiddle: MultipartBody.Part?,
        @Part leftRing: MultipartBody.Part?,
        @Part leftLittle: MultipartBody.Part?,
        @Part rightThumb: MultipartBody.Part?,
        @Part rightIndex: MultipartBody.Part?,
        @Part rightMiddle: MultipartBody.Part?,
        @Part rightRing: MultipartBody.Part?,
        @Part rightLittle: MultipartBody.Part?
    ): Response<FingerScanApiResponse>

    @POST("fingerprintscan1")
    suspend fun fingerPrintScan1(
        @Header("Authorization") auth: String,
        @Query("userData_id") userDataId: String,
        @Body fingerPrintScan1Request: FingerPrintScan1Request
    ): Response<FingerScanApiResponse>

///todo new work raw image upload

    @Multipart
    @PATCH("fingerprintscanImageSave")
    suspend fun fingerprintscanImageSave(
        @Header("Authorization") auth: String,
        @Query("userData_id") userDataId: String,
        @Part leftThumbOrg: MultipartBody.Part?,
        @Part leftIndexOrg: MultipartBody.Part?,
        @Part leftMiddleOrg: MultipartBody.Part?,
        @Part leftRingOrg: MultipartBody.Part?,
        @Part leftLittleOrg: MultipartBody.Part?,
        @Part rightThumbOrg: MultipartBody.Part?,
        @Part rightIndexOrg: MultipartBody.Part?,
        @Part rightMiddleOrg: MultipartBody.Part?,
        @Part rightRingOrg: MultipartBody.Part?,
        @Part rightLittleOrg: MultipartBody.Part?
    ): Response<FingerScanApiResponse>


    ////////todo Atd work start
   /* @POST("AtdScan")
    suspend fun AtdResultFinal(
        @Header("Authorization") auth: String,
        @Query("userData_id") userDataId: String,
        @Body atdResultFinal: AtdResultFinal
    ): Response<FingerScanApiResponse>*/

    ////////todo Atd work end

}

object RetrofitInstance {

    // 1. Lenient Gson
    private val gson = GsonBuilder()
        .setLenient()
        .create()

    // 2. Custom OkHttpClient with 10 Minutes Write Timeout
    private val client = OkHttpClient.Builder()
        .connectTimeout(60, TimeUnit.SECONDS)
        .readTimeout(60, TimeUnit.SECONDS)
        .writeTimeout(600, TimeUnit.SECONDS) // 10 Minute Upload Timeout
        .build()

    private const val BASE_URL = "https://apidaksh.dakshtest.com/api/admin/"

    val apiService: ApiService by lazy {
        Retrofit.Builder()
            .baseUrl(BASE_URL)
            .client(client)
            .addConverterFactory(GsonConverterFactory.create(gson))
            .build()
            .create(ApiService::class.java)
    }
}
