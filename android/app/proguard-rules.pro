# Flutter generic rules
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes Exceptions
-keepattributes SourceFile,LineNumberTable
-keepattributes RuntimeVisibleAnnotations, RuntimeVisibleParameterAnnotations
-keepattributes RuntimeInvisibleAnnotations, RuntimeInvisibleParameterAnnotations

# Keep generic type info (needed by bloc, get_it, dartz)
-keepclassmembers class * {
    java.lang.Class class$;
}

# Keep enum classes (used heavily in bloc states/events)
-keepclassmembers enum * {
    **[] $VALUES;
    *;
}

# Flutter engine
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Dart VM
-keep class dart.** { *; }

# Bloc / FlutterBloc
-keep class * extends bloc.** { *; }
-keep class * extends flutter_bloc.** { *; }
-dontwarn bloc.**
-dontwarn flutter_bloc.**

# GetIt
-keep class * implements get_it.** { *; }
-dontwarn get_it.**

# Dartz
-keep class dartz.** { *; }
-dontwarn dartz.**

# Equatable
-keep class equatable.** { *; }
-dontwarn equatable.**

# Supabase / Realtime / PostgREST
-keep class supabase.** { *; }
-keep class postgrest.** { *; }
-keep class realtime.** { *; }
-keep class gotrue.** { *; }
-keep class storage_client.** { *; }
-keep class functions_client.** { *; }
-dontwarn supabase.**
-dontwarn postgrest.**
-dontwarn realtime.**
-dontwarn gotrue.**
-dontwarn storage_client.**
-dontwarn functions_client.**

# Dio
-keep class dio.** { *; }
-dontwarn dio.**

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# Flutter InAppWebView
-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }
-dontwarn com.pichillilorenzo.flutter_inappwebview.**

# Mobile Scanner
-keep class com.mintware.** { *; }
-dontwarn com.mintware.**

# Cached Network Image
-keep class com.baseflow.** { *; }
-dontwarn com.baseflow.**

# Workmanager
-keep class be.tramckrijte.workmanager.** { *; }
-dontwarn be.tramckrijte.workmanager.**

# Flutter Slidable
-keep class com.letsgo.** { *; }
-dontwarn com.letsgo.**

# Flutter Map
-keep class com.infoworld.** { *; }
-dontwarn com.infoworld.**

# Google Maps Flutter
-keep class io.flutter.plugins.googlemaps.** { *; }
-dontwarn io.flutter.plugins.googlemaps.**

# Geolocator
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

# Image Picker
-keep class io.flutter.plugins.imagepicker.** { *; }
-dontwarn io.flutter.plugins.imagepicker.**

# Share Plus
-keep class io.flutter.plugins.share.** { *; }
-dontwarn io.flutter.plugins.share.**

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }
-dontwarn io.flutter.plugins.pathprovider.**

# Shared Preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.sharedpreferences.**

# SQFlite
-keep class com.tekartik.sqflite.** { *; }
-dontwarn com.tekartik.sqflite.**

# URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }
-dontwarn io.flutter.plugins.urllauncher.**

# Rive
-keep class app.rive.rive.** { *; }
-dontwarn app.rive.rive.**

# Passkeys
-keep class com.corbado.passkeys_android.** { *; }
-keep class com.corbado.passkeys_doctor.** { *; }
-dontwarn com.corbado.passkeys_android.**
-dontwarn com.corbado.passkeys_doctor.**

# WebView Flutter
-keep class io.flutter.plugins.webviewflutter.** { *; }
-dontwarn io.flutter.plugins.webviewflutter.**

# Package Info Plus
-keep class io.flutter.plugins.packageinfo.** { *; }
-dontwarn io.flutter.plugins.packageinfo.**

# Device Info Plus
-keep class io.flutter.plugins.deviceinfo.** { *; }
-dontwarn io.flutter.plugins.deviceinfo.**

# Play Core (needed by Flutter PlayStoreDeferredComponentManager)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Keep all model/data classes used for JSON serialization
-keep class com.shiplink.app.** { *; }

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
    public static int i(...);
}