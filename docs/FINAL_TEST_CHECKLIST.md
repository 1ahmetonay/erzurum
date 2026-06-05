# Final Test Checklist

## Firebase Auth

- [ ] Giriş yokken Auth ekranı açılıyor.
- [ ] Google ile giriş başarılı oluyor.
- [ ] Giriş sonrası Home ekranına yönleniyor.
- [ ] `users/{uid}` dokümanı oluşuyor veya güncelleniyor.

## Firestore Seed

- [ ] Debug modda `/dev/seed` açılıyor.
- [ ] Release modda `/dev/seed` erişilemiyor.
- [ ] Seed butonu tasks, rewards, recycling points ve leaderboard verilerini yazıyor.
- [ ] Seed tekrar çalıştırıldığında aynı veriler çoğalmıyor.

## Home

- [ ] Kullanıcı adı görünüyor.
- [ ] Toplam puan ve haftalık puan görünüyor.
- [ ] Atık kaydı sayısı gerçek `waste_logs` sayısından geliyor.
- [ ] Aktif görev sayısı gerçek progress verisine göre görünüyor.
- [ ] Veri boş veya geç gelirse ekran çökmüyor.

## Scan QR

- [ ] Gerçek QR scanner açılıyor.
- [ ] Debug modda demo QR butonları görünüyor.
- [ ] QR okutunca `waste_logs` approved kaydı oluşuyor.
- [ ] Kullanıcı puanı artıyor.
- [ ] Görev progress artıyor.
- [ ] Görev tamamlanırsa bonus ve tamamlanan görev bilgisi görünüyor.
- [ ] Aynı QR kısa sürede tekrar okutulursa kullanıcı dostu cooldown hatası görünüyor.

## Photo Upload

- [ ] Kamera ile fotoğraf seçilebiliyor.
- [ ] Galeri ile fotoğraf seçilebiliyor.
- [ ] Fotoğraf Storage'a yükleniyor.
- [ ] `waste_logs` pending kaydı oluşuyor.
- [ ] UI `inceleme için alındı` mesajını gösteriyor.

## Tasks Progress

- [ ] Firestore tasks listeleniyor.
- [ ] Progress `users/{uid}/task_progress` üzerinden geliyor.
- [ ] Tamamlanan görev yeşil/check/tamamlandı durumda görünüyor.
- [ ] Kış görevleri Kış sekmesinde görünüyor.

## Rewards Redemption

- [ ] Kullanıcı puanı görünüyor.
- [ ] Puan yeterliyse Kullan butonu aktif oluyor.
- [ ] Kullan deyince `redemptions` kaydı oluşuyor.
- [ ] `totalPoints` düşüyor.
- [ ] `stockCount` azalıyor.
- [ ] CouponDialog gerçek kupon kodunu gösteriyor.
- [ ] Kodu kopyala çalışıyor.

## Map Point Report

- [ ] Recycling points görünüyor.
- [ ] Filtreler çalışıyor.
- [ ] Point detail sheet açılıyor.
- [ ] QR Kodu Göster çalışıyor.
- [ ] Yol Tarifi Al harita uygulamasını veya Google Maps linkini açıyor.
- [ ] Bozuk Bildir `point_reports` kaydı oluşturuyor.

## Leaderboard

- [ ] Bireysel kategorisi çalışıyor.
- [ ] Mahalle kategorisi çalışıyor.
- [ ] Kampüs kategorisi çalışıyor.
- [ ] Okul kategorisi çalışıyor.
- [ ] Veri yoksa empty state düzgün görünüyor.

## Firestore Rules

- [ ] Auth olmayan kullanıcı Firestore verilerine erişemiyor.
- [ ] Kullanıcı yalnızca kendi user, waste log, redemption, point report ve task progress verisini yazabiliyor.
- [ ] Seed/admin koleksiyonlarına client write kapalı.
- [ ] Demo reward stock decrement kuralı redemption akışını engellemiyor.

## Storage Rules

- [ ] Auth olmayan kullanıcı Storage'a erişemiyor.
- [ ] Kullanıcı yalnızca kendi `waste_photos/{uid}` yoluna yazabiliyor.
- [ ] 5 MB üstü veya image olmayan yüklemeler reddediliyor.

## Android Cihaz Testi

- [ ] Google giriş çalışıyor.
- [ ] Android APK kurulum testi tamamlandı.
- [ ] Kamera izni testi tamamlandı.
- [ ] QR okutma testi gerçek QR ile tamamlandı.
- [ ] Fotoğraf yükleme testi Storage kaydıyla doğrulandı.
- [ ] Firebase rules deploy testi tamamlandı.
- [ ] Ödül kupon testi tamamlandı.
- [ ] Bozuk bildir testi `point_reports` kaydıyla doğrulandı.
- [ ] İnternet kapalı/Firestore hata testi kullanıcı dostu hata gösteriyor.
- [ ] Kamera izni ve QR tarama çalışıyor.
- [ ] Fotoğraf çekme ve galeri seçimi çalışıyor.
- [ ] Harita yol tarifi dış uygulamada açılıyor.

## iOS Cihaz Testi

- [ ] Google giriş çalışıyor.
- [ ] Kamera izni ve QR tarama çalışıyor.
- [ ] Fotoğraf çekme ve galeri seçimi çalışıyor.
- [ ] Harita yol tarifi dış uygulamada açılıyor.

## Web Testi

- [ ] Google giriş popup ile çalışıyor.
- [ ] Firestore stream ekranları yükleniyor.
- [ ] QR demo butonları debug modda çalışıyor.
- [ ] Responsive layout taşma yapmıyor.
