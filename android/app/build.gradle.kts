import java.util.Properties
import java.io.FileInputStream

// 加载 key.properties
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")

val localProperties = Properties().apply {
    load(rootProject.file("local.properties").inputStream())
}

val flutterVersionCode = (localProperties["flutter.versionCode"] as String?)?.toInt() ?: 1
val flutterVersionName = localProperties["flutter.versionName"] as String? ?: "1.0.0"

if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ai.wallet"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.ai.wallet"
        minSdk = 24
        targetSdk = 36
        versionCode = flutterVersionCode
        versionName = flutterVersionName

        manifestPlaceholders["GETUI_APPID"] = "your appid"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    signingConfigs {
        getByName("debug") {
            // 使用默认 debug.keystore（AGP 会自动配置，一般不用手动写）
        }
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                val storeFilePath = keystoreProperties.getProperty("storeFile")
                if (!storeFilePath.isNullOrBlank()) {
                    storeFile = file(storeFilePath)
                }
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        getByName("release") {
            // CI 环境（没有 key.properties）走 debug 签名，避免报错
            signingConfig = if (!keystorePropertiesFile.exists() || System.getenv("CI") == "true") {
                signingConfigs.getByName("debug")
            } else {
                signingConfigs.getByName("release")
            }

            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    buildFeatures {
        prefab = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.android.play:core:1.10.3")
    implementation("com.google.android.play:core-ktx:1.8.1")
    implementation("com.google.crypto.tink:tink-android:1.12.0")
    implementation("com.google.code.findbugs:jsr305:3.0.2")
    implementation("com.google.errorprone:error_prone_annotations:2.18.0")
    implementation("javax.annotation:javax.annotation-api:1.3.2")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    implementation("com.getui:gtsdk:3.3.12.0")  // 个推 SDK
    implementation("com.getui:gtc:3.2.18.0")
}
