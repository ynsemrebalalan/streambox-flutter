# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# media_kit
-keep class com.alexmercerind.** { *; }
-keep class media.kit.** { *; }

# sqflite
-keep class io.flutter.plugins.sqflite.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
