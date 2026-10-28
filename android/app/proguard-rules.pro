# Flutter Framework Keep Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }

# DAKSH Native Activities, Models & Services
-keep class com.daksh.daksh.** { *; }
-keepclassmembers class com.daksh.daksh.** { *; }
-keep class com.daksh.daksh.ui.screens.** { *; }
-keep class com.daksh.daksh.data.remote.** { *; }
-keep class com.daksh.daksh.model.** { *; }

# OpenCV C++ & ML Kit JNI Keep Rules
-keep class org.opencv.** { *; }
-dontwarn org.opencv.**
-keep class com.daksh.ml.** { *; }
-dontwarn com.daksh.ml.**

# TensorFlow Lite Models
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.**

# Retrofit, Gson & OkHttp
-keepattributes Signature, InnerClasses, EnclosingMethod, *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**


-keep class kotlin.coroutines.Continuation
# Flutter Play Core (deferred components) - not used, ignore missing classes
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication