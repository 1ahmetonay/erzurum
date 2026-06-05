# AtıkAvı Erzurum Demo Akışı

Bu doküman jüri demosu öncesi Firebase hazırlığı, demo seed verileri ve 2 dakikalık sunum sırasını özetler.

## Firebase Hazırlığı

```bash
firebase login --reauth
firebase use atikavi-erzurum
firebase deploy --only firestore:rules,storage
```

Uygulamayı çalıştırmadan önce:

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
```

## Demo Seed Data

1. Uygulamayı debug modda başlat.
2. Google ile giriş yap.
3. Tarayıcıda veya uygulama route'unda `/dev/seed` ekranını aç.
4. `Demo Verilerini Firestore'a Yükle` butonuna bas.

Seed işlemi `tasks`, `rewards`, `recycling_points` ve `leaderboard` verilerini deterministik doküman ID'leriyle yazar. Aynı butona tekrar basmak veriyi çoğaltmaz; mevcut dokümanları günceller.

`/dev/seed` route'u yalnızca `kDebugMode` içinde tanımlıdır. Release build'de route eklenmez ve erişim `/home` ekranına yönlendirilir.

## Demo QR İçerikleri

QR tarayıcı ve debug demo butonları uygulamada `qrCode` alanını okur. Gerçek okutulacak QR metinleri:

- `ATIKAVI_POINT_YAKUTIYE` - Yakutiye Geri Dönüşüm Merkezi
- `ATIKAVI_POINT_ZERO_WASTE_CAFE` - Erzurum Sıfır Atık Kafe
- `ATIKAVI_POINT_ATAUNI` - Atatürk Üniversitesi Kampüs Toplama Noktası

İlgili Firestore doküman ID'leri:

- `yakutiye_recycling_center`
- `erzurum_zero_waste_cafe`
- `atauni_campus_point`

## QR Kod Oluşturma

Demo QR görseli oluşturmak için herhangi bir QR üretici aracında yukarıdaki `ATIKAVI_POINT_*` değerlerinden birini metin olarak gir. Uygulama içinden Map ekranında bir nokta seçip `QR Kodu Göster` butonuyla da aynı QR değeri görüntülenebilir ve kopyalanabilir.

## 2 Dakikalık Jüri Demo Sırası

1. Auth ekranını göster, Google ile giriş yap ve Home'a geçişi göster.
2. Home'da kullanıcı adı, Dadaş Puan, haftalık puan, atık kaydı ve aktif görev sayılarını göster.
3. Map ekranında filtreleri değiştir, bir nokta seç, `QR Kodu Göster`, `Yol Tarifi Al` ve `Bozuk Bildir` akışlarını göster.
4. Scan ekranında debug QR butonlarından birini kullan veya QR kod okut; `waste_logs`, puan artışı ve görev ilerleme sonucunu göster.
5. Fotoğraf yükleyip `inceleme için alındı` pending akışını göster.
6. Tasks ekranında günlük, haftalık ve kış görevlerini; tamamlanan görevde yeşil/check durumunu göster.
7. Rewards ekranında puanı yeterli bir ödülü kullan; kupon kodunu ve kopyalama aksiyonunu göster.
8. Leaderboard ekranında Bireysel, Mahalle, Kampüs ve Okul sekmelerini dolaş.

## Demo Öncesi Hızlı Kontrol

- Firestore rules ve Storage rules deploy edildi.
- Debug seed bir kez çalıştırıldı.
- Google Auth yetkili domainleri doğru.
- Kamera, galeri ve QR izinleri gerçek cihazda test edildi.
- QR tekrar okutma cooldown mesajı kullanıcı dostu görünüyor.
