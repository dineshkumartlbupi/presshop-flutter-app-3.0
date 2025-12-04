
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}


android {
    namespace = "com.presshop.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.presshop.app"
        minSdk = 24
        targetSdk = 35
        versionCode = 45
        versionName = "1.0.30"

        ndk {
            abiFilters.addAll(listOf("arm64-v8a", "armeabi-v7a"))
        }
    }

    // signingConfigs {
    //     create("release") {
    //         val storeFilePath = keystoreProperties["storeFile"] as String?
    //         if (storeFilePath != null) {
    //             keyAlias = keystoreProperties["keyAlias"] as String?
    //             keyPassword = keystoreProperties["keyPassword"] as String?
    //             storeFile = file(storeFilePath)
    //             storePassword = keystoreProperties["storePassword"] as String?
    //         } else {
    //             println("⚠️ storeFile not found in keystore.properties!")
    //         }
    //     }
    // }

    signingConfigs {
        create("release") {
            storeFile = file("presshop_jks.jks")  
            storePassword = "presshop_jks"
            keyAlias = "key"
            keyPassword = "presshop_jks"
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            ndk {
                abiFilters += listOf("arm64-v8a", "armeabi-v7a")
            }
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
