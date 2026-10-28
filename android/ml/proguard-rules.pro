# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.kts.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile


## --- CRITICAL: keep enum + its methods ---
#-keep class org.tensorflow.lite.support.image.ColorSpaceType { *; }
#
## --- Keep all image processing internals ---
#-keep class org.tensorflow.lite.support.image.** { *; }
#
## --- Keep tensor containers ---
#-keep class org.tensorflow.lite.support.tensorbuffer.** { *; }
#
## --- Keep common ops (NormalizeOp, CastOp) ---
#-keep class org.tensorflow.lite.support.common.** { *; }
#
## --- Prevent enum optimization ---
#-keepclassmembers enum org.tensorflow.lite.support.image.ColorSpaceType { *; }
#
#-dontwarn org.tensorflow.lite.support.**