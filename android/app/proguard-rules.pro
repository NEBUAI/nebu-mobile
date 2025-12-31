# ProGuard rules for Nebu Mobile (Updated for Flutter 3.x+ / 2025)

# Flutter - Core
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Flutter - Keep GeneratedPluginRegistrant
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Dart - Keep for debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# Google Play Core (para deferred components)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Retrofit & OkHttp
-dontwarn okhttp3.**
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }
-keepattributes Signature
-keepattributes Exceptions
-keepattributes *Annotation*

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Models (ajusta según tus paquetes)
-keep class com.nebu.mobile.data.models.** { *; }
-keep class com.nebu.mobile.core.network.** { *; }

# Riverpod
-keep class * extends com.riverpod.** { *; }

# Google Sign In
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Bluetooth
-keep class android.bluetooth.** { *; }

# Camera
-keep class androidx.camera.** { *; }

# WebRTC / LiveKit
-keep class org.webrtc.** { *; }
-keepattributes InnerClasses

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# ========== FLUTTER PACKAGES - 2025 UPDATES ==========

# JSON Serialization (json_annotation / json_serializable)
-keepattributes *Annotation*
-keep class **$*.g.dart { *; }
-keep class **.g.dart { *; }
-keep class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Dio (HTTP Client)
-keep class io.flutter.plugins.** { *; }
-keepclassmembers class * {
    @retrofit2.http.* <methods>;
}

# Easy Localization (CRÍTICO)
-keep class easy_localization.** { *; }
-keep class * extends easy_localization.** { *; }

# Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# Shared Preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Flutter Blue Plus (Bluetooth)
-keep class com.lib.flutter_blue_plus.** { *; }
-dontwarn com.lib.flutter_blue_plus.**

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }

# Camera
-keep class io.flutter.plugins.camera.** { *; }

# Mobile Scanner (QR)
-keep class dev.steenbakker.mobile_scanner.** { *; }

# Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Just Audio
-keep class com.ryanheise.just_audio.** { *; }

# Google Sign In
-keep class io.flutter.plugins.googlesignin.** { *; }
