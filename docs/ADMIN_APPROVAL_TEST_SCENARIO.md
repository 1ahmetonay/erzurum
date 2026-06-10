# Admin Onay Test Senaryosu

Bu senaryo Functions emulator veya güvenli demo Firebase projesi üzerinde admin onay akışını doğrulamak için kullanılır.

1. Normal kullanıcı kayıt olur.
2. Kullanıcı kirli bölge bildirir.
3. Kullanıcı kirli bölge için temizlik etkinliği oluşturur.
4. Kullanıcı etkinlik creator olduğu için başlangıç katılımcısıdır; gerekirse başka kullanıcı etkinliğe katılır.
5. Creator kanıt fotoğrafı yükler.
6. `cleanup_events/{id}.status` değeri `pendingApproval` olur.
7. `cleanup_events/{id}.approvalStatus` değeri `pending` olur.
8. `cleanup_proofs/{cleanupEventId}.status` değeri `pending` olur.
9. Admin kullanıcı giriş yapar.
10. Admin `/admin/cleanup-approvals` ekranından kaydı açar.
11. Admin onaylar.
12. `approveCleanupEvent` callable function çalışır.
13. Event `completed`, dirty area `cleaned`, proof `approved` olur.
14. Katılımcıların `totalPoints` ve `weeklyPoints` alanları artar.
15. `pointsAwarded == true` olduğu için aynı event yeniden puan dağıtamaz.
16. Red senaryosu için yeni bir event oluşturulur ve kanıt gönderilir.
17. Admin red sebebi girerek reddeder.
18. Event `planned`, `approvalStatus: rejected`, proof `rejected` olur ve puan verilmez.

## Beklenen Hata Kontrolleri

- Admin olmayan kullanıcı onay denerse `permission-denied`.
- Giriş yapmamış kullanıcı callable function çağırırsa `unauthenticated`.
- Var olmayan event id ile çağrı yapılırsa `not-found`.
- Onay beklemeyen event onaylanırsa `failed-precondition`.
- Eksik veya geçersiz veri gönderilirse `invalid-argument`.
