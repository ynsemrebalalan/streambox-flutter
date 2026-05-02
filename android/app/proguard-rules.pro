# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# media_kit
-keep class com.alexmercerind.** { *; }
-keep class media.kit.** { *; }

# sqflite
-keep class io.flutter.plugins.sqflite.** { *; }

# RevenueCat (Adim 22 Phase G — IAP)
-keep class com.revenuecat.** { *; }
-keep class com.android.billingclient.** { *; }

# Firebase Auth + Google Sign-In
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}
