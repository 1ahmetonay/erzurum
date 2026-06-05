# Firebase Security Notes

Bu kurallar AtikAvi Erzurum MVP/demo akislari icin yazildi.

## Kapsam

- Auth olmayan kullanicilar Firestore ve Storage verilerine erisemez.
- `users/{uid}`, `waste_logs`, `redemptions`, `point_reports` ve `task_progress` yazimlari kullanici sahipligi ile sinirlanir.
- `recycling_points`, `tasks` ve leaderboard entry yazimlari client tarafina kapatilir.
- `rewards` seed/admin verisi olarak korunur; demo redemption akisi icin yalnizca `stockCount` degerinin 1 azalmasina ve `updatedAt` degisimine izin verilir.
- Storage `waste_photos/{uid}/{fileName}` yolu yalnizca ilgili authenticated kullaniciya aciktir.

## Production Notlari

Client transaction ile puan artirma/dusurme production icin ideal degildir.

- QR puan verme Cloud Functions + Admin SDK ile dogrulanmalidir.
- Task bonus puanlari Cloud Functions tarafinda hesaplanmalidir.
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

Deploy oncesi onerilen Flutter kontrolleri:

```sh
flutter pub get
dart format lib test
flutter analyze
flutter test
```
