# Firebase Configuration Troubleshooting Guide

## 🔥 Firebase Yazma Testi Başarısız - Çözüm Rehberi

### 1. Firestore Database Rules (En Yaygın Sorun)

**Sorunu Kontrol Et:**
- Firebase Console → Firestore Database → Rules
- Mevcut kuralları kontrol et

**Test İçin Geçici Kurallar:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

**Üretim İçin Güvenli Kurallar:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 2. Authentication Provider Ayarları

**Kontrol Et:**
- Firebase Console → Authentication → Sign-in method
- Email/Password provider'in aktif olduğundan emin ol
- Authorized domains listesini kontrol et

### 3. Firebase Project Configuration

**firebase_options.dart dosyasını kontrol et:**
- Doğru project ID
- Geçerli API keys
- Platform-specific configuration

### 4. Network ve Permissions

**Kontrol Et:**
- İnternet bağlantısı
- Firewall settings
- Antivirus Firebase bağlantısını engelliyor mu?

### 5. Firebase Console Kontrol Listesi

✅ **Project Setup:**
- [ ] Firebase project oluşturuldu
- [ ] Billing account bağlandı (gerekirse)
- [ ] Project aktif durumda

✅ **Authentication:**
- [ ] Authentication servisi etkinleştirildi
- [ ] Email/Password provider aktif
- [ ] Authorized domains eklendi

✅ **Firestore Database:**
- [ ] Firestore Database oluşturuldu
- [ ] Database rules yapılandırıldı
- [ ] Location seçildi

✅ **App Configuration:**
- [ ] firebase_options.dart doğru yapılandırıldı
- [ ] Dependencies yüklendi
- [ ] Firebase.initializeApp() çalışıyor

### 6. Hata Mesajları ve Çözümleri

**"permission-denied"**
→ Firestore rules çok kısıtlayıcı, yukarıdaki test kurallarını kullan

**"operation-not-allowed"**
→ Authentication provider aktif değil

**"unavailable"**
→ Firebase servisi geçici olarak kullanılamıyor, tekrar dene

**"network-request-failed"**
→ İnternet bağlantısı problemi

### 7. Test Süreci

1. Firebase Test widget'ını çalıştır
2. Bağlantı testini geç
3. "Hesap Testi" butonuna bas
4. Hata mesajını incele
5. Yukarıdaki çözümleri uygula

### 8. Adım Adım Sorun Giderme

**Adım 1:** Firestore rules'u test kurallarıyla değiştir
**Adım 2:** Firebase Test'i tekrar çalıştır
**Adım 3:** Hala hata varsa Authentication settings'i kontrol et
**Adım 4:** firebase_options.dart'ı yeniden yapılandır
**Adım 5:** Project billing ve quota'ları kontrol et

Bu adımlardan sonra hesap oluşturma sorunu çözülmelidir.