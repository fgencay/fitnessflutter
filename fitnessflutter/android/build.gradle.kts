// android/build.gradle.kts  (ROOT)

// Sadece plugin tanımları; uygulama modülünde (app) uygulanacaklar
plugins {
    id("com.android.application") apply false
    id("org.jetbrains.kotlin.android") apply false
    id("com.google.gms.google-services") apply false
}

// İsteğe bağlı: temizleme görevi
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

