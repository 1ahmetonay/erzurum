# İlk Admin Kurulumu

İlk admin kullanıcı uygulama içinden atanamaz. Bunun nedeni `setAdminClaim` callable function'ının da admin custom claim gerektirmesidir.

## Güvenli Yaklaşım

1. Firebase Console veya Auth kullanıcı listesinden ilk admin olacak kullanıcının UID değerini al.
2. Firebase Admin SDK kullanabilen güvenli bir ortamda service account JSON dosyasını hazırla.
3. Service account dosyasını repo içine koyma ve commit etme.
4. `GOOGLE_APPLICATION_CREDENTIALS` ortam değişkenini service account dosyasına yönlendir.
5. `tools/admin/set_first_admin.js` scriptini çalıştır.

```sh
cd tools/admin
export GOOGLE_APPLICATION_CREDENTIALS="/güvenli/yol/service-account.json"
node set_first_admin.js USER_UID
```

Script başarılı olunca:

- Firebase Auth custom claim: `{ admin: true }`
- Firestore: `users/{uid}.role = "admin"`

Kullanıcının admin yetkisini uygulamada görmesi için çıkış/giriş yapması veya ID token yenilemesi gerekir.

## Güvenlik Notları

- `serviceAccountKey.json`, `*service-account*.json` ve `*.local.json` dosyaları `.gitignore` kapsamındadır.
- Service account dosyasını paylaşma.
- İlk admin atandıktan sonra diğer admin işlemleri `/admin/users` ekranı ve `setAdminClaim` callable function ile yapılabilir.
- Production ortamında admin rol yönetimini mümkünse sınırlı operasyon makinelerinde ve denetlenebilir süreçlerle yap.
