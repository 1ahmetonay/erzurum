# İlk Admin Scripti

Bu script yalnızca ilk admin kullanıcısını atamak için operasyon amaçlıdır. Service account JSON dosyasını repo içine koyma ve commit etme.

## Kullanım

```sh
cd tools/admin
export GOOGLE_APPLICATION_CREDENTIALS="/güvenli/yol/service-account.json"
node set_first_admin.js USER_UID
```

Script:

- `USER_UID` için Auth custom claim olarak `{ admin: true }` atar.
- Firestore `users/{uid}.role` alanını `admin` yapar.
- `updatedAt` alanını server timestamp ile günceller.

Kullanıcının yeni custom claim'i alması için uygulamadan çıkış/giriş yapması veya ID token yenilemesi gerekir.
