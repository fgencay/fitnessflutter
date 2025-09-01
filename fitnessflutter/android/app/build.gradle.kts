plugins {
    id("com.android.application")
     id("dev.flutter.flutter-plugin") 
    kotlin("android")
    id("com.google.gms.google-services")
    
}

android {
    namespace = "com.example.fitnessflutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.fitnessflutter"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    buildTypes {
        release {
           
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}


kotlin {
    jvmToolchain(8)
}

flutter {
    source = "../.."
}
