plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ai.wallet"
    compileSdk = flutter.compileSdkVersion
//    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.ai.wallet"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

//        ndk {
//            abiFilters.add("armeabi-v7a")
//            abiFilters.add("arm64-v8a")
//            abiFilters.add("x86")
//            abiFilters.add("x86_64")
//        }
    }


    signingConfigs {
        create("release") {
            storeFile = file("/Users/admin/StudioProjects/untitled1/android/wallet_key.jks")
            storePassword = "123123"
            keyAlias = "key"
            keyPassword = "123123"
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }

//        optimization {
//            codeShrinkerProguard false
//            codeShrinkerR8 true
//        }

    }

//    packagingOptions {
//        pickFirst 'lib/**/libTrustWalletCore.so' // 避免重复库冲突
//    }

//    packagingOptions {
//        pickFirst 'lib/**/libwallet_core.so'
//    }

    buildFeatures {
        prefab = true
    }
}

flutter {
    source = "../.."
//    ndkVersion = "27.0.12077973"
}

dependencies {
    implementation("com.google.android.play:core:1.10.3")
    implementation("com.google.android.play:core-ktx:1.8.1")

    implementation("com.google.crypto.tink:tink-android:1.12.0")
    // 添加缺失的注解库
    implementation("com.google.code.findbugs:jsr305:3.0.2")
    // 确保已有error-prone注解.
    compileOnly("com.google.auto.value:auto-value-annotations:1.9")
    implementation("com.google.errorprone:error_prone_annotations:2.18.0")
    implementation("javax.annotation:javax.annotation-api:1.3.2")
}