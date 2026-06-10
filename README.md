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
- Arkadaş isteği, temizlik grubu oluşturma ve grup daveti MVP akışı

## Teknik Stack

- Flutter / Dart
- Firebase Auth, Cloud Firestore, Firebase Storage
- Riverpod, GoRouter
- mobile_scanner, image_picker, qr_flutter, url_launcher
- Flutter test, analyzer ve Firebase security rules

## Kirli Bölge Fotoğrafı, Konum ve AI Analiz Hazırlığı

Kirli bölge bildiriminde fotoğraf zorunludur. Kullanıcı mevcut konumunu
kullanabilir veya doğrulanan enlem/boylam değerlerini manuel girebilir. Konum
seçilmezse Erzurum merkez koordinatları kullanılır.

Fotoğraflar Firebase Storage'da
`dirty_area_photos/{userId}/{timestamp}.jpg` yoluna yüklenir ve indirme URL'si
`dirty_areas.photoUrl` alanına yazılır. AI analiz alanları ve normalize sonuç
modeli ileride Gemini entegrasyonu için hazırdır; gerçek Gemini API bağlantısı
henüz yapılmamıştır. API anahtarları repoya eklenmemeli, production analizleri
Cloud Functions veya güvenli bir backend üzerinden çalıştırılmalıdır.

## Kurulum

```bash
flutter pub get
flutter run
```

Firebase projesi bu repo için `atikavi-erzurum` olarak yapılandırılmıştır. Yeni ortamda FlutterFire ayarları gerekiyorsa `lib/firebase_options.dart` dosyasını proje Firebase bilgileriyle güncelle.

## Firebase Setup

Google Auth sağlayıcısını Firebase Console'da etkinleştir. Firestore ve Storage kurallarını deploy etmeden önce Firebase CLI ile giriş yap:

Flutter web'de Google Sign-In çalışması için [web/index.html](/Users/ahmetonay/projects/atikavi_erzurum/web/index.html) içindeki `google-signin-client_id` meta tag'i gerçek Web OAuth Client ID ile değiştirilmelidir. Bu ID Firebase Console veya Google Cloud Console içindeki OAuth 2.0 Credentials bölümünden alınır. Android client id değil, Web client id kullanılmalıdır.

```bash
firebase login --reauth
firebase use atikavi-erzurum
firebase deploy --only firestore:rules,storage
```

Güvenlik kapsamı ve production notları için [docs/FIREBASE_SECURITY_NOTES.md](/Users/ahmetonay/projects/atikavi_erzurum/docs/FIREBASE_SECURITY_NOTES.md) dosyasına bak.

## Firebase Functions ve Admin Kurulumu

Admin onay, temizlik kanıtı red/onay ve custom claim yönetimi için callable Functions iskeleti `functions/` altında bulunur.

```bash
cd functions
npm install
npm run build
npm run serve
npm run deploy
```

Flutter tarafında Functions dependency değişikliklerinden sonra:

```bash
flutter pub get
```

Node 20 önerilir. Yerel Node v24 kullanılırsa `npm install` sırasında engine uyarısı görülebilir; bunun nedeni Functions runtime hedefinin Node 20 olmasıdır.

Emulator test adımları için [docs/FUNCTIONS_EMULATOR_TEST_GUIDE.md](/Users/ahmetonay/projects/atikavi_erzurum/docs/FUNCTIONS_EMULATOR_TEST_GUIDE.md), ilk admin kurulumu için [docs/FIRST_ADMIN_SETUP.md](/Users/ahmetonay/projects/atikavi_erzurum/docs/FIRST_ADMIN_SETUP.md) dosyasını kullan.

İlk admin kullanıcısının `admin` custom claim'i uygulama dışından Firebase Admin SDK veya güvenli bir CLI script ile atanmalıdır.

## Arkadaş ve Grup Daveti MVP

Sosyal temizlik akışı şu Firestore koleksiyonlarını kullanır: `user_connections`, `cleanup_groups`, `group_invitations`. Arkadaş arama MVP'de `users` koleksiyonundan sınırlı client-side filtreleme yapar; production için indeksli arama veya ayrı bir arama servisi önerilir.

Grup oluşturma, üyelik ve davet kabulü client transaction ile `cleanup_events` katılımcı listesini senkronize eder. Production'da bu çapraz doküman güncellemeleri Cloud Functions + Admin SDK tarafına taşınmalıdır.

## Demo Sosyal Veriler

Arkadaşlarım, Arkadaşlık İstekleri, Grup Davetleri ve Temizlik Grupları
ekranları Firestore kaydı bulunmadığında yerel tanıtım verilerini otomatik gösterir.
Bu kayıtlar Firestore'a yazılmaz ve yazma gerektiren aksiyonları kapalıdır.
Gerçek sosyal kayıtlar geldiğinde provider'lar onları öncelikli gösterir. Yerel sahte
veriler production sosyal akışı tamamlandığında kaldırılmalıdır.

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
