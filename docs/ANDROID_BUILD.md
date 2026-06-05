# Android Build Notları

Bu doküman AtıkAvı Erzurum demo APK/AAB hazırlığı için Android ayarlarını ve build komutlarını özetler.

## Kimlik ve Firebase

- Android `applicationId`: `com.atikavi.atikavi_erzurum`
- Android namespace: `com.atikavi.atikavi_erzurum`
- Firebase Android package name: `com.atikavi.atikavi_erzurum`
- Firebase config dosyası: `android/app/google-services.json`
- FlutterFire Android options: `lib/firebase_options.dart`

`applicationId` değiştirilirse Firebase Console'da aynı package name ile yeni Android app oluşturulmalı, yeni `google-services.json` indirilmeli ve `lib/firebase_options.dart` FlutterFire CLI ile yeniden üretilmelidir. Demo için package name değiştirilmedi.

## Uygulama Adı ve İzinler

- Görünen Android uygulama adı: `AtıkAvı Erzurum`
- Gerekli izinler:
  - `android.permission.CAMERA`
  - `android.permission.INTERNET`

Konum izni şu an eklenmedi; demo akışında aktif cihaz konumu okunmuyor. Yol tarifi Google Maps linkiyle dış uygulamada açılır.

## Release Notları

Release build şu an debug signing config ile imzalanır. Bu demo APK kurulumu için yeterlidir; Play Store veya kalıcı dağıtım için release keystore oluşturulmalı ve `android/app/build.gradle.kts` içinde release signing yapılandırılmalıdır.

Minify/ProGuard demo release build'de kapalı bırakılmıştır. Firebase, QR scanner ve image picker akışlarında gereksiz shrinker riski alınmaz.

## Build Komutları

```bash
flutter clean
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
flutter build appbundle --release
```

Beklenen çıktılar:

- Debug APK: `build/app/outputs/flutter-apk/app-debug.apk`
- Release APK: `build/app/outputs/flutter-apk/app-release.apk`
- Release AAB: `build/app/outputs/bundle/release/app-release.aab`
