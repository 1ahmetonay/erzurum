# Functions Emulator Test Guide

Bu doküman AtıkAvı Erzurum callable Functions akışını local emulator ile test etmek için hazırlanmıştır.

## Gerekli Araçlar

- Firebase CLI
- Node 20 önerilir. Node v24 ile `npm install` sırasında engine uyarısı görülebilir; build çalışsa bile deploy ortamı Node 20 olmalıdır.
- Flutter SDK
- Java runtime, Firestore emulator için gerekir.

## Kurulum

```sh
cd functions
npm install
npm run build
```

Flutter dependency değiştiyse:

```sh
flutter pub get
```

## Emulator Çalıştırma

Tüm tanımlı emulatorlar:

```sh
firebase emulators:start
```

Sadece bu akış için gerekli emulatorlar:

```sh
firebase emulators:start --only auth,firestore,functions,storage
```

Emulator UI:

```text
http://localhost:4000
```

Portlar `firebase.json` içinde tanımlıdır:

- Auth: `9099`
- Functions: `5001`
- Firestore: `8080`
- Storage: `9199`
- UI: `4000`

## Flutter Uygulamasını Emulator'a Bağlama

Varsayılan olarak production Firebase kullanılır. Emulator bağlantısı kapalıdır.

Dosya:

```text
lib/core/config/firebase_emulator_config.dart
```

Geçici local test için:

```dart
const useFirebaseEmulators = true;
```

Android emulator host değeri `10.0.2.2`, web/local desktop host değeri `localhost` olarak ayarlanır.

Test bitince değeri tekrar `false` yap.

## İlk Admin

Callable admin fonksiyonları `context.auth.token.admin === true` bekler. İlk admin uygulama içinden atanamaz.

İlk admin için:

```sh
cd tools/admin
export GOOGLE_APPLICATION_CREDENTIALS="/güvenli/yol/service-account.json"
node set_first_admin.js USER_UID
```

Detaylar için:

```text
docs/FIRST_ADMIN_SETUP.md
```

## Callable Functions Test Sırası

1. Normal kullanıcı ile kirli bölge ve cleanup event oluştur.
2. Creator kanıt fotoğrafı yüklesin.
3. Event `pendingApproval`, proof `pending` olsun.
4. Admin claim'i olan kullanıcı ile `/admin/cleanup-approvals` ekranını aç.
5. Onayla: `approveCleanupEvent`.
6. Event `completed`, dirty area `cleaned`, proof `approved`, katılımcı puanları artmış olmalı.
7. Aynı event için tekrar onay çağrısı `failed-precondition` dönmeli.
8. Yeni bir pending event oluştur ve reddet: `rejectCleanupEvent`.
9. Event `planned`, proof `rejected`, puanlar değişmemiş olmalı.
10. `/admin/users` ekranından `setAdminClaim` ile başka kullanıcıya admin ver/kaldır.

Detaylı uçtan uca senaryo:

```text
docs/ADMIN_APPROVAL_TEST_SCENARIO.md
```

## Hata Kodları

### unauthenticated

Ne zaman olur: Kullanıcı giriş yapmadan callable function çağırır.

Kullanıcı mesajı: “Bu işlem için giriş yapmalısınız.”

Nasıl test edilir: Auth emulator'da çıkış yapıp admin callable function çağır.

### permission-denied

Ne zaman olur: Kullanıcının `admin` custom claim'i yoktur.

Kullanıcı mesajı: “Bu işlem için admin yetkiniz yok.”

Nasıl test edilir: Normal kullanıcı ile admin onay ekranından işlem dene.

### not-found

Ne zaman olur: `cleanupEventId` Firestore'da yoktur.

Kullanıcı mesajı: “İlgili kayıt bulunamadı.”

Nasıl test edilir: Var olmayan event id ile callable function çağır.

### failed-precondition

Ne zaman olur: Event onay beklemiyordur, daha önce onaylanmıştır veya `pointsAwarded` true olmuştur.

Kullanıcı mesajı: “Bu işlem mevcut durumda yapılamaz.”

Nasıl test edilir: Tamamlanmış event için tekrar onay çağır.

### invalid-argument

Ne zaman olur: `cleanupEventId`, `targetUid` gibi zorunlu alanlar eksiktir.

Kullanıcı mesajı: “Gönderilen bilgiler geçersiz.”

Nasıl test edilir: Eksik data ile callable function çağır.

### internal

Ne zaman olur: Beklenmeyen server hatası oluşur.

Kullanıcı mesajı: “İşlem sırasında beklenmeyen bir hata oluştu.”

Nasıl test edilir: Emulator loglarında beklenmeyen exception üretmeyecek şekilde normalde görülmemelidir; server logları kontrol edilir.

## Olası Hatalar

- Node engine uyarısı: Local Node v24 ise görülebilir. Functions runtime Node 20 olacak şekilde `functions/package.json` ayarlandı.
- Admin claim görünmüyor: Kullanıcı çıkış/giriş yapmalı veya ID token yenilenmeli.
- Flutter emulator'a bağlanmıyor: `useFirebaseEmulators` false kalmış olabilir.
- Android emulator Firestore'a bağlanmıyor: Host `10.0.2.2` kullanılmalı.
- Storage upload reddediliyor: Dosya image content type olmalı ve 5 MB altında kalmalı.
