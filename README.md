# AtıkAvı Erzurum

AtıkAvı Erzurum, Erzurum'da geri dönüşüm davranışını QR tarama, görevler, puanlar, sıralama ve ödül kuponlarıyla oyunlaştıran Flutter MVP uygulamasıdır.

## Özellikler

- Firebase Auth ile Google girişi ve `users/{uid}` profil oluşturma
- Firestore stream tabanlı Home, Map, Tasks, Rewards ve Leaderboard ekranları
- QR tarama ile `waste_logs` kaydı, puan kazanımı ve görev ilerleme güncellemesi
- Fotoğrafla atık bildirimi ve Storage'a yüklenen pending inceleme kayıtları
- Geri dönüşüm noktası filtreleri, QR gösterimi, yol tarifi ve bozuk nokta bildirimi
- Ödül kullanımı, stok düşümü, puan düşümü ve kupon kodu oluşturma
- Debug modda kontrollü Firestore demo seed ekranı

## Teknik Stack

- Flutter / Dart
- Firebase Auth, Cloud Firestore, Firebase Storage
- Riverpod, GoRouter
- mobile_scanner, image_picker, qr_flutter, url_launcher
- Flutter test, analyzer ve Firebase security rules

## Kurulum

```bash
flutter pub get
flutter run
```

Firebase projesi bu repo için `atikavi-erzurum` olarak yapılandırılmıştır. Yeni ortamda FlutterFire ayarları gerekiyorsa `lib/firebase_options.dart` dosyasını proje Firebase bilgileriyle güncelle.

## Firebase Setup

Google Auth sağlayıcısını Firebase Console'da etkinleştir. Firestore ve Storage kurallarını deploy etmeden önce Firebase CLI ile giriş yap:

```bash
firebase login --reauth
firebase use atikavi-erzurum
firebase deploy --only firestore:rules,storage
```

Güvenlik kapsamı ve production notları için [docs/FIREBASE_SECURITY_NOTES.md](/Users/ahmetonay/projects/atikavi_erzurum/docs/FIREBASE_SECURITY_NOTES.md) dosyasına bak.

## Stitch MCP Tasarım Notu

MVP UI akışı Stitch MCP ile oluşturulan mobil ekran kompozisyonuna göre Flutter'da uygulanmıştır. Büyük redesign yerine mevcut kart, rozet, kış görevi ve alt navigasyon dili korunmalıdır.

## Demo Seed

Debug modda `/dev/seed` ekranı Firestore demo verilerini yükler. Route yalnızca `kDebugMode` içinde eklenir; release build'de erişilemez. Seed deterministik doküman ID'leri kullandığı için tekrar çalıştırıldığında aynı kayıtları günceller, yeni kopyalar oluşturmaz.

Detaylı demo akışı ve QR içerikleri için [docs/DEMO_AKISI.md](/Users/ahmetonay/projects/atikavi_erzurum/docs/DEMO_AKISI.md) dosyasını kullan.

## Android Build

Android APK/AAB hazırlığı, package name, izinler ve release signing notları için [docs/ANDROID_BUILD.md](/Users/ahmetonay/projects/atikavi_erzurum/docs/ANDROID_BUILD.md) dosyasına bak.

## Test Komutları

```bash
dart format lib test
flutter analyze
flutter test
```

Uçtan uca cihaz kontrol listesi için [docs/FINAL_TEST_CHECKLIST.md](/Users/ahmetonay/projects/atikavi_erzurum/docs/FINAL_TEST_CHECKLIST.md) dosyasını takip et.

## GitHub Repo Kullanımı

- `main` branch'i demo için çalışır durumda tutulmalı.
- Firebase config ve rules değişiklikleri PR içinde açıkça belirtilmeli.
- Büyük UI redesign, demo polish ve güvenlik kuralı değişiklikleri ayrı commitlerde tutulmalı.
