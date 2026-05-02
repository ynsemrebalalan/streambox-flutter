# Firestore Security Rules — v1.9.0 Cloud Sync

Phase 2 Cloud Sync için Firestore Console'a aşağıdaki kuralları **manuel** ekle.

## Kurallar

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Pro user kendi cloud verisini okuyabilir/yazabilir.
    // users/{uid}/playlists, favorites, watchlist, history alt koleksiyonlar.
    match /users/{userId}/{collection}/{docId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Mevcut anon device-based playlist backup (FirebaseSyncService — koru).
    match /streambox_devices/{deviceId}/{document=**} {
      allow read, write: if request.auth != null;
    }

    // Mevcut global config (proxy secret, openai key) — read-only.
    match /streambox_config/{docId} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // Diğer her şey — yasak.
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

## Nasıl uygulanır

1. https://console.firebase.google.com → projeyi aç
2. Sol menü → **Firestore Database**
3. Sekme **Rules**
4. Yukarıdaki kuralları yapıştır (mevcudu üzerine yaz)
5. **Publish**

## Test

- Pro user A → kendi `users/{A_uid}/favorites/{key}`'ine yazabilmeli
- User A → User B'nin `users/{B_uid}/favorites/{key}`'ine yazAMAMALI
- Anon user → `users/*` path'lerine erişEMEMELİ
- Anon user → `streambox_devices/{kendiDevice}/playlists/*`'a yazabilmeli

## Index gereksinimleri

Şimdilik composite index gerekmiyor. İleride history sıralaması için
`updatedAt DESC` query eklenirse Firebase Console otomatik index önerir.

## Maliyet notu

Pro user bazında ortalama:
- 5 playlist × 2KB = 10KB
- 50 favorite × 200B = 10KB
- 30 watchlist × 200B = 6KB
- 200 history × 100B = 20KB

Toplam: ~46KB/user. Free tier 1GB → 22K user'a yeter. Ölçeklendikçe
budget alert'i kur (10$ aylık limit).
