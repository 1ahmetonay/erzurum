# ♻️ AtıkAvı Erzurum — Codex Geliştirme Rehberi

> **Flutter ile Geri Dönüşümü Oyuna Çeviren Şehir Uygulaması**  
> Bu döküman, Codex'e (veya herhangi bir AI kod asistanına) projeyi adım adım geliştirtmek için hazırlanmıştır.

---

## 📋 İçindekiler

1. [Proje Genel Bakış](#1-proje-genel-bakış)
2. [Teknik Stack](#2-teknik-stack)
3. [Klasör Yapısı](#3-klasör-yapısı)
4. [Firebase Kurulum ve Yapılandırma](#4-firebase-kurulum-ve-yapılandırma)
5. [Veri Modeli (Firestore)](#5-veri-modeli-firestore)
6. [Uygulama Mimarisi (Riverpod)](#6-uygulama-mimarisi-riverpod)
7. [Ekran Detayları ve Codex Komutları](#7-ekran-detayları-ve-codex-komutları)
   - [7.1 Auth Ekranı](#71-auth-ekranı)
   - [7.2 Ana Sayfa (Dashboard)](#72-ana-sayfa-dashboard)
   - [7.3 Atık Tara](#73-atık-tara)
   - [7.4 Harita](#74-harita)
   - [7.5 Görevler](#75-görevler)
   - [7.6 Sıralama](#76-sıralama)
   - [7.7 Ödüller](#77-ödüller)
8. [Renk ve Tema Sistemi](#8-renk-ve-tema-sistemi)
9. [Routing](#9-routing)
10. [Güvenlik Kuralları (Firestore Rules)](#10-güvenlik-kuralları-firestore-rules)
11. [Test Senaryoları](#11-test-senaryoları)
12. [Geliştirme Sırası (Önerilen)](#12-geliştirme-sırası-önerilen)

---

## 1. Proje Genel Bakış

**AtıkAvı Erzurum**, Erzurum'daki bireylerin geri dönüşüm davranışını oyunlaştırma (gamification) yoluyla değiştiren bir Flutter mobil uygulamasıdır.

### Temel Kavramlar

| Kavram | Açıklama |
|--------|----------|
| **Dadaş Puan** | Kullanıcının geri dönüşüm yaparak kazandığı uygulama içi puan birimi |
| **Atık Kaydı** | QR okutma veya fotoğraf yükleme ile oluşturulan geri dönüşüm kaydı |
| **Görev** | Günlük/haftalık/kış görevleri — tamamlandığında puan verir |
| **Leaderboard** | Bireysel, mahalle, kampüs ve okul bazlı sıralama tabloları |
| **Ödül** | Dadaş Puan karşılığında kazanılabilen kupon/indirim/fiziksel ödüller |

### Hedef Kullanıcılar
- Atatürk Üniversitesi ve Erzurum Teknik Üniversitesi öğrencileri
- Erzurum merkez mahallelerindeki vatandaşlar
- Esnaf (Sıfır Atık Kafe, fırınlar, lokantalar)
- Okul ve kurumlar

---

## 2. Teknik Stack

```yaml
Flutter: ">=3.19.0"
Dart: ">=3.3.0"

dependencies:
  # Firebase
  firebase_core: ^3.3.0
  firebase_auth: ^5.1.4
  cloud_firestore: ^5.2.1
  firebase_storage: ^12.1.3

  # Auth
  google_sign_in: ^6.2.1

  # Harita
  google_maps_flutter: ^2.7.0
  geolocator: ^12.0.0

  # QR / Barkod
  mobile_scanner: ^5.2.3

  # Kamera / Fotoğraf
  image_picker: ^1.1.2

  # State Management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Router
  go_router: ^14.2.7

  # UI / Animasyon
  lottie: ^3.1.2
  fl_chart: ^0.68.0
  shimmer: ^3.0.0
  cached_network_image: ^3.3.1

  # Yardımcılar
  intl: ^0.19.0
  uuid: ^4.4.2
  permission_handler: ^11.3.1

dev_dependencies:
  build_runner: ^2.4.11
  riverpod_generator: ^2.4.3
  flutter_gen_runner: ^5.6.0
```

---

## 3. Klasör Yapısı

```
lib/
├── main.dart
├── firebase_options.dart              # FlutterFire CLI üretir
│
├── core/
│   ├── theme/
│   │   ├── app_theme.dart             # ThemeData tanımları
│   │   ├── app_colors.dart            # Renk sabitleri
│   │   └── app_text_styles.dart       # TextStyle tanımları
│   ├── router/
│   │   └── app_router.dart            # GoRouter yapılandırması
│   ├── constants/
│   │   ├── firestore_paths.dart       # Koleksiyon yolları
│   │   └── app_constants.dart         # Genel sabitler
│   └── utils/
│       ├── formatters.dart            # Tarih, puan formatlama
│       └── validators.dart            # Form validasyonları
│
├── models/
│   ├── user_model.dart
│   ├── waste_log_model.dart
│   ├── recycling_point_model.dart
│   ├── task_model.dart
│   ├── leaderboard_model.dart
│   └── reward_model.dart
│
├── repositories/
│   ├── auth_repository.dart
│   ├── user_repository.dart
│   ├── waste_repository.dart
│   ├── task_repository.dart
│   ├── leaderboard_repository.dart
│   └── reward_repository.dart
│
├── providers/
│   ├── auth_provider.dart
│   ├── user_provider.dart
│   ├── waste_provider.dart
│   ├── task_provider.dart
│   ├── leaderboard_provider.dart
│   └── reward_provider.dart
│
├── features/
│   ├── auth/
│   │   └── auth_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── widgets/
│   │       ├── stat_card.dart
│   │       ├── nearby_point_card.dart
│   │       └── weekly_chart.dart
│   ├── scan/
│   │   ├── scan_screen.dart
│   │   └── widgets/
│   │       ├── qr_scanner_view.dart
│   │       ├── photo_confirm_view.dart
│   │       └── success_overlay.dart
│   ├── map/
│   │   ├── map_screen.dart
│   │   └── widgets/
│   │       ├── map_filter_bar.dart
│   │       └── point_detail_sheet.dart
│   ├── tasks/
│   │   ├── tasks_screen.dart
│   │   └── widgets/
│   │       ├── task_card.dart
│   │       └── winter_task_banner.dart
│   ├── leaderboard/
│   │   ├── leaderboard_screen.dart
│   │   └── widgets/
│   │       ├── leaderboard_tab.dart
│   │       └── rank_card.dart
│   └── rewards/
│       ├── rewards_screen.dart
│       └── widgets/
│           ├── reward_card.dart
│           └── coupon_dialog.dart
│
└── shared/
    └── widgets/
        ├── app_bottom_nav.dart
        ├── loading_overlay.dart
        ├── error_widget.dart
        └── puan_badge.dart
```

---

## 4. Firebase Kurulum ve Yapılandırma

### Adım 1 — FlutterFire CLI

```bash
# FlutterFire CLI kur
dart pub global activate flutterfire_cli

# Firebase projesini bağla
flutterfire configure --project=atikavi-erzurum
```

Bu komut `lib/firebase_options.dart` dosyasını otomatik oluşturur.

### Adım 2 — main.dart Başlatma

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: AtikAviApp()));
}

class AtikAviApp extends ConsumerWidget {
  const AtikAviApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'AtıkAvı Erzurum',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
```

### Firebase Console Yapılandırması

Firebase Console'da aşağıdakileri aktif et:

- **Authentication** → Google Sign-In'i etkinleştir
- **Firestore Database** → Production mode'da oluştur
- **Storage** → Etkinleştir
- **Google Maps** → `android/app/src/main/AndroidManifest.xml` içine API key ekle

---

## 5. Veri Modeli (Firestore)

### 5.1 `users/{uid}`

```dart
// lib/models/user_model.dart

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final int totalPoints;          // Toplam Dadaş Puan
  final int weeklyPoints;         // Bu haftaki puan (leaderboard için)
  final String neighborhood;      // Mahalle adı
  final String? schoolOrCampus;   // Okul veya kampüs (opsiyonel)
  final List<String> badges;      // Kazanılan rozet ID'leri
  final int level;                // 1-10 seviye
  final DateTime createdAt;

  // Firestore'dan dönüştürme
  factory UserModel.fromFirestore(DocumentSnapshot doc) { ... }
  Map<String, dynamic> toFirestore() { ... }
}
```

**Firestore Yapısı:**
```
users/
  {uid}/
    displayName: "Ahmet Yılmaz"
    email: "ahmet@gmail.com"
    photoUrl: "https://..."
    totalPoints: 350
    weeklyPoints: 80
    neighborhood: "Yıldızkent"
    schoolOrCampus: "Atatürk Üniversitesi"
    badges: ["ilk_atik", "kis_koruyucusu", "100_puan"]
    level: 3
    createdAt: Timestamp
```

---

### 5.2 `waste_logs/{logId}`

```dart
class WasteLogModel {
  final String id;
  final String userId;
  final String wasteType;         // "plastic" | "glass" | "paper" | "battery" | "oil"
  final String verificationMethod; // "qr" | "photo" | "barcode"
  final String? photoUrl;         // Firebase Storage URL
  final String? qrPointId;        // Hangi geri dönüşüm noktası
  final GeoPoint location;
  final int pointsEarned;
  final DateTime loggedAt;
}
```

**Firestore Yapısı:**
```
waste_logs/
  {logId}/
    userId: "abc123"
    wasteType: "plastic"
    verificationMethod: "qr"
    photoUrl: null
    qrPointId: "point_001"
    location: GeoPoint(39.90, 41.27)
    pointsEarned: 10
    loggedAt: Timestamp
```

---

### 5.3 `recycling_points/{pointId}`

```dart
class RecyclingPointModel {
  final String id;
  final String name;
  final String type;              // "plastic" | "glass" | "paper" | "battery" | "oil" | "electronic" | "cafe"
  final GeoPoint location;
  final String address;
  final String qrCode;            // QR içeriği (pointId)
  final bool isActive;
  final bool isBroken;            // Vatandaş bildirimi
  final String? imageUrl;
  final Map<String, dynamic>? workingHours;
}
```

---

### 5.4 `tasks/{taskId}`

```dart
class TaskModel {
  final String id;
  final String title;
  final String description;
  final String type;              // "daily" | "weekly" | "social" | "education" | "winter"
  final int pointReward;
  final String? requiredAction;   // "scan_plastic" | "invite_friend" | "solve_quiz" vb.
  final int? requiredCount;       // Kaç kez yapılacak
  final bool isWinterOnly;        // Kış Görevi mi?
  final String iconEmoji;
}
```

---

### 5.5 `leaderboard/{category}` — Alt Koleksiyonlar

```
leaderboard/
  individual/
    entries/
      {uid}/
        userId: "abc123"
        displayName: "Ahmet"
        photoUrl: "..."
        weeklyPoints: 80
        totalPoints: 350
        rank: 1
  neighborhood/
    entries/
      {neighborhoodName}/
        name: "Yıldızkent"
        weeklyPoints: 1200
        memberCount: 45
        rank: 1
  campus/
    entries/
      {campusName}/
        name: "Atatürk Üniversitesi"
        weeklyPoints: 5600
        memberCount: 230
        rank: 1
  school/
    entries/
      {schoolName}/
        ...
```

---

### 5.6 `rewards/{rewardId}`

```dart
class RewardModel {
  final String id;
  final String title;
  final String description;
  final int requiredPoints;
  final String category;          // "discount" | "transport" | "physical" | "donation" | "certificate"
  final String sponsor;           // "Sıfır Atık Kafe" | "Erzurum Kart" vb.
  final String iconEmoji;
  final bool isActive;
  final int? stockCount;          // null = sınırsız
}
```

---

## 6. Uygulama Mimarisi (Riverpod)

### Auth Provider

```dart
// lib/providers/auth_provider.dart

@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return FirebaseAuth.instance.authStateChanges();
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
    // Yeni kullanıcıysa Firestore'a kaydet
    await ref.read(userRepositoryProvider).createUserIfNotExists(userCred.user!);
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }
}
```

### User Provider

```dart
// lib/providers/user_provider.dart

@riverpod
Stream<UserModel?> currentUser(CurrentUserRef ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);
  return ref.read(userRepositoryProvider).watchUser(user.uid);
}

@riverpod
class PointsNotifier extends _$PointsNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> addPoints(String userId, int points) async {
    await FirebaseFirestore.instance.doc('users/$userId').update({
      'totalPoints': FieldValue.increment(points),
      'weeklyPoints': FieldValue.increment(points),
    });
  }
}
```

---

## 7. Ekran Detayları ve Codex Komutları

> ⚡ Aşağıdaki her bölümü Codex'e **ayrı ayrı prompt** olarak ver.  
> Her prompt, ilgili dosyanın tam olarak oluşturulmasını ister.

---

### 7.1 Auth Ekranı

**Dosya:** `lib/features/auth/auth_screen.dart`

**Codex Promptu:**
```
Flutter ile lib/features/auth/auth_screen.dart dosyasını oluştur.

Gereksinimler:
- Yeşil tonlu gradient arka plan (#1B5E20 → #2E7D32)
- Ortada büyük ♻️ ikonu (animated rotation)
- "AtıkAvı Erzurum" başlığı (beyaz, bold)
- "Atığını dönüştür, puanını kazan, Erzurum'u temizle." alt başlığı
- "Google ile Giriş Yap" butonu (beyaz arka plan, Google ikonu)
- Buton tıklandığında AuthNotifier.signInWithGoogle() çağrılır
- Yüklenirken CircularProgressIndicator göster
- ConsumerStatefulWidget kullan (Riverpod)
- Hata durumunda SnackBar göster
```

---

### 7.2 Ana Sayfa (Dashboard)

**Dosya:** `lib/features/home/home_screen.dart`

**Codex Promptu:**
```
Flutter ile lib/features/home/home_screen.dart dosyasını oluştur.

Gereksinimler:
- AppBar: "Merhaba, {displayName} 👋" ve sağda profil fotoğrafı
- Üstte yeşil banner: "Bu hafta {weeklyPoints} Dadaş Puan kazandın!"
- 2x2 StatCard grid:
    * Toplam Puan (yeşil)
    * Dönüştürülen Atık (adet)
    * Bu Haftaki Sıralama (#124 gibi)
    * Aktif Görevler (adet)
- "En Yakın Nokta" kartı: konum ikonu + mesafe + "Yol Tarifi Al" butonu
- Haftalık puan grafiği (fl_chart, son 7 gün çubuk grafik, yeşil)
- "Aktif Görevler" başlığı altında max 3 görev önizlemesi
- currentUser provider'ından veri çek
- Shimmer efekti ile loading state
```

**StatCard Widget:**
```
lib/features/home/widgets/stat_card.dart dosyasını oluştur.

Parametreler: title (String), value (String), icon (IconData), color (Color)
Tasarım: rounded card, subtle shadow, ikon üstte, değer büyük ve bold, başlık küçük
```

---

### 7.3 Atık Tara

**Dosya:** `lib/features/scan/scan_screen.dart`

**Codex Promptu:**
```
Flutter ile lib/features/scan/scan_screen.dart dosyasını oluştur.

Üç sekmeli yapı (TabBar):
1. "QR Tara" sekmesi:
   - mobile_scanner ile kamera görünümü
   - Köşeli kare overlay (yeşil çerçeve)
   - QR okunduğunda: pointId Firestore'da doğrulanır
   - Başarılı ise: pointsEarned kadar puan ekle, SuccessOverlay göster
   
2. "Fotoğraf" sekmesi:
   - image_picker ile kameradan fotoğraf çek
   - Atık türü seçimi (Plastik / Cam / Kağıt / Pil / Yağ) — ChoiceChip
   - "Kaydet" butonu → Firebase Storage'a yükle, waste_log oluştur, +10 puan ekle
   - Yükleme progress göster

3. "Barkod" sekmesi:
   - mobile_scanner ile barkod modu
   - Barkod okunduğunda ürün ambalaj türünü göster (mock data ile)
   - "En Yakın {tür} Kutusunu Göster" butonu

SuccessOverlay widget: tam ekran yeşil overlay, ✓ ikonu, "X Dadaş Puan Kazandın!", 
Lottie konfeti animasyonu, 2 saniye sonra otomatik kapan
```

---

### 7.4 Harita

**Dosya:** `lib/features/map/map_screen.dart`

**Codex Promptu:**
```
Flutter ile lib/features/map/map_screen.dart dosyasını oluştur.

Gereksinimler:
- google_maps_flutter ile tam ekran harita
- Kullanıcının konumu mavi nokta olarak göster (geolocator)
- Firestore'dan recycling_points çek, her noktayı custom marker ile göster:
    * Plastik → yeşil ikon
    * Cam → mavi ikon
    * Kağıt → sarı ikon
    * Pil → kırmızı ikon
    * Yağ → turuncu ikon
    * Sıfır Atık Kafe → özel ☕ ikon
- Üstte FilterBar (horizontal scroll): Tümü, Plastik, Cam, Kağıt, Pil, Yağ, Kafe
- Marker tıklandığında PointDetailSheet (DraggableScrollableSheet):
    * Nokta adı, türü, adresi
    * Mesafe
    * "QR Kodu Göster" butonu (o noktanın QR'ını modal olarak göster)
    * "Yol Tarifi Al" butonu (Google Maps deep link)
    * "Bozuk Bildir" butonu (isBroken: true yap)
- Sağ altta FAB: "Konumuma Git"
```

---

### 7.5 Görevler

**Dosya:** `lib/features/tasks/tasks_screen.dart`

**Codex Promptu:**
```
Flutter ile lib/features/tasks/tasks_screen.dart dosyasını oluştur.

Gereksinimler:
- En üstte WinterTaskBanner (sadece Kasım-Mart aylarında göster):
    * Mavi/kar beyazı gradyan arka plan
    * "❄️ Kış Görevi Modu Aktif!" yazısı
    * Kış görevlerinin toplam tamamlanma yüzdesi

- Görev kategorileri (ExpansionTile veya TabBar):
    * 🌅 Günlük Görevler
    * 📅 Haftalık Görevler
    * 👥 Sosyal Görevler
    * 🎓 Eğitim Görevleri
    * ❄️ Kış Görevleri

- Her görev için TaskCard widget:
    * İkon (emoji)
    * Başlık ve açıklama
    * Puan değeri (sağda yeşil badge)
    * İlerleme göstergesi (requiredCount > 1 ise LinearProgressIndicator)
    * "Tamamlandı" ise gri + ✓, "Aktif" ise yeşil + "Başla" butonu
    
- Görev tamamlandığında: puan ekle + rozet kontrolü yap
- Firestore'dan tasks koleksiyonunu dinle
```

---

### 7.6 Sıralama

**Dosya:** `lib/features/leaderboard/leaderboard_screen.dart`

**Codex Promptu:**
```
Flutter ile lib/features/leaderboard/leaderboard_screen.dart dosyasını oluştur.

Gereksinimler:
- 4 sekmeli TabBar:
    1. 👤 Bireysel
    2. 🏘️ Mahalle
    3. 🎓 Kampüs
    4. 🏫 Okul

- Her sekme için LeaderboardTab widget:
    * İlk 3 kişi/yer için podium tasarımı (1.= altın, 2.= gümüş, 3.= bronz)
    * Altında ListView ile diğer sıralamalar
    * Her satır: sıra no | isim/profil | puan | fark (geçen haftaya göre ↑↓)
    
- Kullanıcının kendi sırası her zaman altta sabit gösterilir:
    * "Sen: #124 — 350 puan" — sarı arka planla vurgulanır
    
- Haftalık sıfırlanma bilgisi: "Sıralama Pazartesi sıfırlanır" countdown

- Firestore'dan ilgili leaderboard/{category}/entries dinle (limit 50)
```

---

### 7.7 Ödüller

**Dosya:** `lib/features/rewards/rewards_screen.dart`

**Codex Promptu:**
```
Flutter ile lib/features/rewards/rewards_screen.dart dosyasını oluştur.

Gereksinimler:
- Üstte puan özeti kartı: "Bakiyen: {totalPoints} Dadaş Puan 🌱"
- Kategori filtresi (horizontal chip): Tümü | İndirim | Ulaşım | Fiziksel | Bağış | Sertifika

- Her ödül için RewardCard:
    * İkon/emoji
    * Başlık ve sponsor adı
    * Gereken puan (yeşil badge)
    * Kullanıcının puanı yetiyorsa "Kullan" butonu (yeşil, aktif)
    * Yetmiyorsa "X puan daha gerekli" (gri, disabled)
    
- "Kullan" butonuna tıklandığında CouponDialog:
    * "Tebrikler! {rewardTitle} kazandınız."
    * Rastgele oluşturulmuş kupon kodu (UUID)
    * Sponsor bilgisi
    * "Kodu Kopyala" butonu
    * Kullanıcının totalPoints'i güncellenir (eksi puan)
    * Kullanılan ödül waste_logs'a benzeri bir koleksiyona kayıt edilir

- rewards Firestore koleksiyonundan çek, isActive: true filtresi
```

---

## 8. Renk ve Tema Sistemi

```dart
// lib/core/theme/app_colors.dart

class AppColors {
  // Ana Renkler
  static const primary        = Color(0xFF1B5E20);   // Koyu yeşil
  static const primaryDark    = Color(0xFF003300);
  static const primaryLight   = Color(0xFF2E7D32);
  static const accent         = Color(0xFF388E3C);
  static const accentLight    = Color(0xFF66BB6A);

  // Yüzey Renkleri
  static const background     = Color(0xFFF1F8E9);
  static const surface        = Color(0xFFFFFFFF);
  static const cardBg         = Color(0xFFE8F5E9);

  // Atık Türü Renkleri
  static const plastic        = Color(0xFF66BB6A);   // Yeşil
  static const glass          = Color(0xFF29B6F6);   // Mavi
  static const paper          = Color(0xFFFFA726);   // Turuncu
  static const battery        = Color(0xFFEF5350);   // Kırmızı
  static const oil            = Color(0xFFAB47BC);   // Mor
  static const electronic     = Color(0xFF78909C);   // Gri

  // Sıralama Renkleri
  static const gold           = Color(0xFFFFD700);
  static const silver         = Color(0xFFC0C0C0);
  static const bronze         = Color(0xFFCD7F32);

  // Kış Modu
  static const winterBlue     = Color(0xFF1565C0);
  static const winterLight    = Color(0xFFE3F2FD);

  // Metin
  static const textPrimary    = Color(0xFF212121);
  static const textSecondary  = Color(0xFF757575);
  static const textOnPrimary  = Color(0xFFFFFFFF);
}
```

```dart
// lib/core/theme/app_theme.dart

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      showUnselectedLabels: true,
    ),
  );
}
```

---

## 9. Routing

```dart
// lib/core/router/app_router.dart

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isAuthRoute = state.matchedLocation == '/auth';

      if (!isLoggedIn && !isAuthRoute) return '/auth';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (_, __) => const AuthScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => ScaffoldWithNavBar(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/scan', builder: (_, __) => const ScanScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/map', builder: (_, __) => const MapScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/tasks', builder: (_, __) => const TasksScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/leaderboard', builder: (_, __) => const LeaderboardScreen()),
          ]),
        ],
      ),
    ],
  );
}
```

---

## 10. Güvenlik Kuralları (Firestore Rules)

```javascript
// firestore.rules

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Kullanıcı kendi profilini okuyabilir/yazabilir
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }

    // Atık kayıtları: kendi kayıtlarını yaz, herkese oku
    match /waste_logs/{logId} {
      allow read: if request.auth != null;
      allow create: if request.auth.uid == resource.data.userId
                    && request.auth != null;
      allow update, delete: if false;
    }

    // Geri dönüşüm noktaları: herkes okuyabilir, sadece admin yazabilir
    match /recycling_points/{pointId} {
      allow read: if request.auth != null;
      allow write: if false; // Admin SDK ile yazılır
    }

    // Görevler: sadece okuma
    match /tasks/{taskId} {
      allow read: if request.auth != null;
      allow write: if false;
    }

    // Leaderboard: herkes okuyabilir
    match /leaderboard/{category}/entries/{entryId} {
      allow read: if request.auth != null;
      allow write: if false; // Cloud Function ile güncellenir
    }

    // Ödüller: herkes okuyabilir
    match /rewards/{rewardId} {
      allow read: if request.auth != null;
      allow write: if false;
    }
  }
}
```

---

## 11. Test Senaryoları

### Manuel Test Kontrol Listesi

```
AUTH
[ ] Google ile giriş yapılabiliyor
[ ] Çıkış yapıldığında auth ekranına yönlendiriliyor
[ ] Yeni kullanıcı Firestore'a kaydediliyor

DASHBOARD
[ ] Kullanıcı adı ve puanı doğru gösteriliyor
[ ] Haftalık grafik son 7 günü gösteriyor
[ ] En yakın nokta mesafesi hesaplanıyor
[ ] Shimmer loading gösteriliyor

ATIK TARA
[ ] QR okutma Firestore'da noktayı buluyor
[ ] Fotoğraf Firebase Storage'a yükleniyor
[ ] waste_log Firestore'a kaydediliyor
[ ] Puan anında artıyor
[ ] SuccessOverlay + konfeti görünüyor

HARİTA
[ ] Tüm Firestore noktaları marker olarak görünüyor
[ ] Filtre çalışıyor (sadece plastik noktaları göster)
[ ] Marker tıklama detay sheet açıyor
[ ] "Bozuk Bildir" Firestore'u güncelliyor

GÖREVLER
[ ] Kasım-Mart: Kış Banner görünüyor
[ ] Diğer aylar: Kış Banner gizli
[ ] Tamamlanan görev gri görünüyor
[ ] Görev puan ekliyor

SIRALAMA
[ ] 4 sekme çalışıyor
[ ] Kullanıcı kendi sırasını alt çubukta görüyor
[ ] Podium ilk 3 için doğru

ÖDÜLLER
[ ] Yeterli puanı olan "Kullan" butonu aktif
[ ] Yetersiz puan "X puan daha" gösteriyor
[ ] Kupon kodu dialog gösteriyor
[ ] Puan düşüyor
```

---

## 12. Geliştirme Sırası (Önerilen)

Codex ile geliştirirken bu sırayı takip et. Her adımı bitirmeden bir sonrakine geçme.

```
Sprint 1 — Temel Altyapı (1-2 gün)
  ✅ Flutter projesi oluştur (flutter create atikavi_erzurum)
  ✅ pubspec.yaml bağımlılıklarını ekle
  ✅ Firebase projesi kur + flutterfire configure
  ✅ Klasör yapısını oluştur
  ✅ app_colors.dart + app_theme.dart
  ✅ Tüm model sınıflarını yaz (UserModel, WasteLogModel vb.)

Sprint 2 — Auth + Navigation (1 gün)
  ✅ auth_repository.dart + auth_provider.dart
  ✅ AuthScreen (Google Sign-In)
  ✅ app_router.dart (GoRouter + redirect)
  ✅ app_bottom_nav.dart (5 sekme)

Sprint 3 — Dashboard (1 gün)
  ✅ user_repository.dart (Firestore CRUD)
  ✅ StatCard widget
  ✅ HomeScreen (tüm bileşenler)
  ✅ Haftalık grafik (fl_chart)

Sprint 4 — Atık Tara (1-2 gün)
  ✅ waste_repository.dart
  ✅ QR Scanner sekmesi
  ✅ Fotoğraf sekmesi + Storage upload
  ✅ SuccessOverlay + Lottie
  ✅ Puan güncelleme

Sprint 5 — Harita (1 gün)
  ✅ recycling_points Firestore'a seed data ekle
  ✅ MapScreen + custom markers
  ✅ FilterBar
  ✅ PointDetailSheet
  
Sprint 6 — Görevler + Sıralama + Ödüller (2 gün)
  ✅ TasksScreen + WinterTaskBanner
  ✅ LeaderboardScreen (4 sekme)
  ✅ RewardsScreen + CouponDialog

Sprint 7 — Demo Hazırlığı (1 gün)
  ✅ Firestore seed data (noktalar, görevler, ödüller)
  ✅ Demo kullanıcısı oluştur
  ✅ Edge case'leri düzelt
  ✅ Jüri sunumu için demo akışını test et
```

---

## 📝 Codex'e Genel Talimatlar

Codex ile çalışırken her promptun başına şunu ekle:

```
Proje: AtıkAvı Erzurum (Flutter)
Mimari: Riverpod + GoRouter + Firebase
Tema: AppColors ve AppTheme sınıfları tanımlı (yeşil tonlar)
Dil: Türkçe UI metinleri, Dart kodu İngilizce

[Buraya ekran/dosya spesifik promptunu yaz]
```

---

> 🏆 **Başarılar!** Bu rehberi takip ederek Erzurum Sıfır Atık Yarışması için
> güçlü, gerçek hayata bağlı ve teknik olarak etkileyici bir Flutter uygulaması geliştirebilirsin.
>
> *"Atığını dönüştür, puanını kazan, Erzurum'u temizle."*
