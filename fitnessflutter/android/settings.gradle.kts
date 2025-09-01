// android/settings.gradle.kts

pluginManagement {
    val flutterSdkPath = run {
        val props = java.util.Properties()
        file("local.properties").inputStream().use { props.load(it) }
        val p = props.getProperty("flutter.sdk")
        require(p != null) { "flutter.sdk not set in local.properties" }
        p
    }
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    plugins {
        id("com.android.application") version "8.6.1"
        id("org.jetbrains.kotlin.android") version "2.0.20"
        id("com.google.gms.google-services") version "4.4.2"
        id("dev.flutter.flutter-gradle-plugin") version "1.0.0"
    }
}

dependencyResolutionManagement {
   repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        maven { url = uri("${settingsDir.parentFile}/build/host/outputs/repo") }
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
}

rootProject.name = "fitnessflutter"
include(":app")

