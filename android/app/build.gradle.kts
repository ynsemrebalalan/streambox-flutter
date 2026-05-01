import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

android {
    namespace = "com.ynsemrebalalan.iptvai"
    compileSdk = 36
    ndkVersion = "26.3.11579264"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.ynsemrebalalan.iptvai"
        // Firebase BOM 33.x cluster (Analytics, Auth, Firestore) requires minSdk 24.
        // Android 5.x/6.x usage is <1% globally; bump from 21 was already forced
        // by transitive Firebase deps.
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keyPropertiesFile.exists()) {
                keyAlias     = keyProperties["keyAlias"]     as String
                keyPassword  = keyProperties["keyPassword"]  as String
                storeFile    = file(keyProperties["storeFile"] as String)
                storePassword = keyProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (keyPropertiesFile.exists())
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")
            isMinifyEnabled  = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Play Core eski monolith paket (1.10.3) artık modern Firebase deps'in
    // çektiği `core-common:2.0.3` ile sınıf çakıştırıyor (Duplicate class).
    // Eski split sağlamak için ayrılmış modüllere geçiyoruz; R8/keep
    // ihtiyaçları release'de proguard-rules.pro üstünden karşılanır.
    implementation("com.google.android.play:core-common:2.0.3")
    implementation("com.google.android.play:app-update:2.1.0")
    implementation("com.google.android.play:review:2.0.2")
}
