# Firebase Security Notes

Bu kurallar AtikAvi Erzurum MVP/demo akislari icin yazildi.

## Kapsam

- Auth olmayan kullanicilar Firestore ve Storage verilerine erisemez.
- `users/{uid}`, `waste_logs`, `redemptions`, `point_reports` ve `task_progress` yazimlari kullanici sahipligi ile sinirlanir.
- `recycling_points`, `tasks` ve leaderboard entry yazimlari client tarafina kapatilir.
- `rewards` seed/admin verisi olarak korunur; demo redemption akisi icin yalnizca `stockCount` degerinin 1 azalmasina ve `updatedAt` degisimine izin verilir.
- Storage `waste_photos/{uid}/{fileName}` yolu yalnizca ilgili authenticated kullaniciya aciktir.
- Storage `dirty_area_photos/{uid}/{fileName}` yolu yalnizca ilgili authenticated kullaniciya aciktir; dosya en fazla 5 MB ve `image/*` tipinde olmalidir.
- `dirty_areas`, `cleanup_events`, `cleanup_groups`, `group_invitations` ve `user_connections` okumasi MVP'de authenticated kullanicilara aciktir. Client yazimlari kaydi olusturan veya uyelik/davet/baglanti tarafinda dogrudan ilgili kullanici ile sinirlidir.

## Production Notlari

Client transaction ile puan artirma/dusurme production icin ideal degildir.

- QR puan verme Cloud Functions + Admin SDK ile dogrulanmalidir.
- Task bonus puanlari Cloud Functions tarafinda hesaplanmalidir.
- Temizlik etkinligi tamamlama, kanit fotografi ve katilimci Dadas puan dagitimi MVP'de client transaction ile yapilir; production'da Cloud Functions + Admin SDK ile dogrulanmalidir.
- Admin onay akisi MVP'de `users/{uid}.role == "admin"` kontroluyle client transaction uzerinden calisir; production'da admin role yonetimi custom claims ve server-side yetkilendirme ile korunmalidir.
- Temizlik puan dagitimi yalnizca admin onayindan sonra yapilmalidir; production'da kullanicilarin kendi puanlarini dogrudan artirmasi Cloud Functions disinda engellenmelidir.
- Yeni Cloud Functions hazirligi admin onay ve role yonetimini callable functions tarafina tasir:
  - `approveCleanupEvent`
  - `rejectCleanupEvent`
  - `setAdminClaim`
- Callable functions admin kontrolunu `context.auth.token.admin === true` custom claim'i ile yapar.
- Ilk admin kullanicisi uygulama icinden atanamaz; Firebase Admin SDK veya guvenli bir CLI script ile manuel custom claim verilmelidir. Firestore `users/{uid}.role` alanini da `admin` olarak senkron tut.
- Emulator testinde Functions, Firestore ve Auth emulatorlari birlikte calistirilmelidir.
- Emulator test adimlari icin `docs/FUNCTIONS_EMULATOR_TEST_GUIDE.md`, ilk admin operasyonu icin `docs/FIRST_ADMIN_SETUP.md` dosyasini kullan.
- Reward redemption, kullanici puan dusumu ve stok azalmasi tek bir server-side transaction ile yapilmalidir.
- Leaderboard guncellemeleri Cloud Functions ile uretilmelidir.
- Admin/belediye paneli custom claims ile ayrilmali, point report incelemesi client query'lerine acilmamalidir.

## Deploy

Firebase CLI oturumu ve proje secimi:

```sh
firebase login --reauth
firebase use atikavi-erzurum
```

Firestore rules:

```sh
firebase deploy --only firestore:rules
```

Storage rules:

```sh
firebase deploy --only storage
```

Tum rules deploy:

```sh
firebase deploy --only firestore:rules,storage
```

Deploy oncesi rules kontrolu:

```sh
firebase emulators:start --only firestore,storage
```

Emulatorler rules dosyalarini hatasiz yukleyip Firestore `8080` ve Storage `9199` portlarinda dinlemeye baslamadan deploy etme.

Deploy oncesi onerilen Flutter kontrolleri:

```sh
flutter pub get
dart format lib test
flutter analyze
flutter test
```
