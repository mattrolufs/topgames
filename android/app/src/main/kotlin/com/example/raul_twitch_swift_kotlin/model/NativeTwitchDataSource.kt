package com.example.raul_twitch_swift_kotlin.model

import com.jakewharton.retrofit2.adapter.kotlin.coroutines.CoroutineCallAdapterFactory
import com.example.raul_twitch_swift_kotlin.model.response.Pagination
import com.example.raul_twitch_swift_kotlin.model.response.GameEntity
import com.example.raul_twitch_swift_kotlin.model.response.GameEntityResponse
import kotlinx.coroutines.Deferred
import okhttp3.Interceptor
import okhttp3.OkHttpClient
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Path
import retrofit2.http.Query


const val CLIENT_ID = "cblvo3evoxpn8duahtlvdw388dxezr"
const val url = "https://api.twitch.tv/"

interface NativeTwitchDataSource {

    @GET("helix/streams")
    fun getTopGames(@Query("limit") int : Int) : Deferred<GameEntityResponse>

    companion object {
        operator fun invoke(): NativeTwitchDataSource {
            val requestInterceptor = Interceptor {chain ->

                val request = chain.request()
                        .newBuilder()
                        .addHeader("Client-ID", "$CLIENT_ID")
                        .build()

                return@Interceptor chain.proceed(request)
            }

            val okHttpClient = OkHttpClient.Builder()
                    .addInterceptor(requestInterceptor)
                    .build()

            return Retrofit.Builder()
                    .client(okHttpClient)
                    .baseUrl(url)
                    .addCallAdapterFactory(CoroutineCallAdapterFactory())
                    .addConverterFactory(GsonConverterFactory.create())
                    .build()
                    .create(NativeTwitchDataSource::class.java)
        }
    }


}