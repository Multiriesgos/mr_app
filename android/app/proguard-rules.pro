# Flutter engine
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Keep JSON model classes (data layer) — prevents R8 from stripping fields used by jsonDecode/json_serializable
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keep class multiriesgos.multimate.app.** { *; }

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}

# OkHttp / HTTP (if added in future)
-dontwarn okhttp3.**
-dontwarn okio.**

# Suppress warnings for missing classes in release
-dontwarn java.lang.instrument.ClassFileTransformer
-dontwarn sun.misc.SignalHandler
