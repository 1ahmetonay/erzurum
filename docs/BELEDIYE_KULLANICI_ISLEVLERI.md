# AtıkAvı Erzurum Kullanıcı İşlevleri ve Belediyeye Sağladığı Katkılar

## 1. Projenin Genel Amacı

AtıkAvı Erzurum, vatandaşların geri dönüşüm faaliyetlerine daha düzenli katılmasını, çevre sorunlarını konum bilgisiyle bildirmesini ve gönüllü temizlik çalışmalarında bir araya gelmesini desteklemek amacıyla geliştirilen bir mobil uygulama MVP'sidir.

Uygulama; geri dönüşüm noktalarını görünür hale getirme, doğrulanabilir atık kayıtları oluşturma, görev ve puanlarla katılımı teşvik etme, kirli bölgeleri kayıt altına alma ve temizlik etkinlikleri düzenleme işlevlerini aynı yapı altında toplar. Kullanıcı işlemleri Firebase tabanlı kullanıcı, bildirim, etkinlik, görev, puan ve ödül kayıtlarıyla ilişkilendirilir.

Mevcut sürüm bir MVP ve tanıtım sürümüdür. Temel kullanıcı akışlarının önemli bölümü çalışır durumdadır; bazı sıralama, sosyal içerik ve ana sayfa göstergeleri veri bulunmadığında örnek tanıtım verileri gösterebilir. Belediye operasyonlarıyla doğrudan entegrasyon, kapsamlı raporlama paneli ve otomatik yapay zeka analizi ise geliştirmeye açık alanlardır.

## 2. Kullanıcıların Yapabildiği Temel İşlemler

### Giriş, kayıt ve profil işlemleri

Kullanıcılar e-posta ve şifreyle kayıt olabilir, mevcut hesaplarıyla giriş yapabilir veya Google hesabıyla uygulamaya devam edebilir. Kayıt sonrasında kullanıcıya ait profil; ad, e-posta, toplam puan, haftalık puan, mahalle, okul veya kampüs, seviye ve rozet gibi bilgileri taşıyabilecek şekilde oluşturulur.

Profil alanından görünen ad ve temel kullanıcı tercihleri düzenlenebilir. Şifre yenileme e-postası gönderme ve güvenli çıkış yapma işlemleri de desteklenir. Böylece atık kayıtları, bildirimler, görev ilerlemeleri ve ödül kullanımları ilgili kullanıcı hesabıyla eşleştirilir.

### Ana sayfa

Ana sayfa kullanıcının uygulamadaki durumunu tek bakışta görmesini sağlar. Ekranda kullanıcı adı, toplam ve haftalık Dadaş Puan bilgisi, oluşturulan atık kaydı sayısı, aktif görevler ve yakındaki geri dönüşüm noktası gibi bilgiler sunulur.

Kullanıcı ana sayfadan kirli bölge bildirimine, arkadaşlar ve grup davetleri alanına, görev listesine ve haritaya hızlıca geçebilir. Haftalık hareket grafiği ile sıralama ve tasarruf gibi bazı özet göstergeler mevcut MVP'de tanıtım amaçlı sabit veya örnek değer içerebilir; bunların kurumsal raporlama verisi olarak değerlendirilmeden önce gerçek veri kaynaklarına bağlanması gerekir.

### Atık, QR ve fotoğraf kaydı

Kullanıcı atık türünü seçerek geri dönüşüm noktasındaki QR kodunu okutabilir. Sistem QR kodunun kayıtlı, aktif ve arızalı olmayan bir geri dönüşüm noktasına ait olup olmadığını kontrol eder. Uygun bir okutma sonucunda:

- Kullanıcı adına onaylı bir atık kaydı oluşturulur.
- Geri dönüşüm noktası, atık türü, tarih ve konum bilgileri kayda eklenir.
- Atık türüne göre Dadaş Puan hesaplanır.
- İlgili görevlerin ilerlemesi güncellenir.
- Tamamlanan görev varsa görev bonusu kullanıcının puanına eklenir.

Aynı geri dönüşüm noktasının kısa süre içinde tekrar okutulmasına karşı süre kontrolü bulunur. Bu kontrol, tekrar eden veya hatalı puan üretimini azaltmayı amaçlar.

Atık kaydı fotoğrafla da gönderilebilir. Kullanıcı kamera veya galeriden görsel seçer; fotoğraf depolama alanına yüklenir ve kayıt inceleme bekleyen durumda oluşturulur. Fotoğraflı atık kaydında puan doğrudan verilmez; mevcut yapı inceleme sonrasında değerlendirilebilecek bir kayıt üretir.

Tarama ekranında barkod okuma arayüzü de vardır. Mevcut sürüm barkod sonucunu kullanıcıya gösterebilir; barkodu ürün veya atık veri tabanıyla eşleştiren tam doğrulama ve puanlama akışı henüz tamamlanmış değildir.

### Geri dönüşüm noktalarını haritada görme

Uygulama geri dönüşüm noktalarını OpenStreetMap tabanlı harita üzerinde gösterir. Noktalar plastik, cam, kağıt, pil, yağ, elektronik atık ve benzeri türlere göre filtrelenebilir.

Bir nokta seçildiğinde kullanıcı noktanın adını, adresini, türünü, çalışma durumunu ve varsa çalışma saatlerini görebilir. Kullanıcı ayrıca:

- Noktanın QR kodunu görüntüleyebilir.
- Harita uygulaması üzerinden yol tarifi alabilir.
- Noktanın bozuk, dolu, kayıp veya yanlış konumda olduğunu bildirebilir.

Nokta bildirimi kullanıcı, geri dönüşüm noktası, bildirim türü, açıklama, tarih ve bekleyen durum bilgisiyle kaydedilir. Bu kayıtlar belediyenin saha kontrolü ve bakım planlaması için ileride bir yönetim ekranında değerlendirilebilir.

### Görevler

Görev ekranında günlük, haftalık, sosyal, eğitim ve kış dönemi görevleri listelenebilir. Her görev açıklama, hedef işlem, gerekli tekrar sayısı ve puan ödülü içerebilir. Kullanıcı ilerlemesini ve tamamlanma durumunu takip eder.

QR ile yapılan uygun atık kayıtları görev ilerlemesini otomatik olarak artırır. Görev hedefi tamamlandığında tanımlı bonus puan kullanıcı hesabına eklenebilir. Arkadaş daveti, eğitim içeriği veya saha bildirimi gibi görev türleri veri modelinde yer almakla birlikte tüm görev eylemlerinin otomatik ilerleme bağlantıları mevcut MVP'de aynı düzeyde tamamlanmış değildir.

### Puan, sıralama ve ödüller

Dadaş Puan, kullanıcının doğrulanan geri dönüşüm işlemlerinden ve tamamladığı görevlerden kazandığı uygulama içi puandır. Toplam puan ödül kullanımında, haftalık puan ise dönemsel katılımın izlenmesinde kullanılabilir.

Sıralama ekranı bireysel, mahalle, kampüs, okul ve ilçe temelli kategorileri gösterebilecek şekilde hazırlanmıştır. Firestore'da sıralama verisi varsa bu kayıtlar kullanılır; veri yoksa ekran tanıtım amacıyla örnek sıralama gösterebilir. Haftalık sıralamanın otomatik hesaplanması, gizlilik tercihlerinin uygulanması ve düzenli sıfırlanması için sunucu tarafında ek süreç gereklidir.

Ödül ekranında aktif ödüller kategori, gerekli puan, destekçi ve stok bilgileriyle görüntülenir. Yeterli puanı bulunan kullanıcı ödülü kullanabilir. İşlem sonucunda puan düşürülür, stoklu ödüllerde stok azaltılır ve kullanıcı için süreli bir kupon kodu oluşturulur. Gerçek belediye veya işletme uygulamasında kupon doğrulama, stok ve puan işlemlerinin güvenli sunucu servisleri üzerinden yürütülmesi önerilir.

### Eğitim ve bilgilendirme

“Öğren ve Kazan” alanında sıfır atık, geri dönüşümün önemi, atık türleri ve doğru ayrıştırma gibi konular kartlar ve detay sayfaları halinde sunulur. İçerik uygulamanın yerel eğitim dosyasından okunur; dosya yüklenemezse temel bilgilendirme içeriği gösterilir.

Kullanıcının geri dönüşüm sorularını yanıtlaması planlanan yapay zeka destekli asistan ekranda “yakında” olarak belirtilmiştir. Bu asistan ve eğitim sorularına bağlı otomatik görev tamamlama işlevi henüz gerçek bir yapay zeka servisine bağlı değildir.

## 3. Kirli Bölge Bildirimi Süreci

Kirli bölge bildirimi, vatandaşın sahada gördüğü çevre sorununu konum ve fotoğrafla kayıt altına almasını sağlar. Mevcut süreç aşağıdaki şekilde işler:

1. Kullanıcı kirli bölge bildirim ekranını açar.
2. Plastik, cam, kağıt, evsel atık, inşaat atığı veya diğer seçeneklerinden bir veya birden fazla atık türü seçer.
3. Kirlilik seviyesini 1 ile 5 arasında belirtir ve açıklama girer.
4. Kamera veya galeriden bir fotoğraf ekler. Bildirimin gönderilebilmesi için fotoğraf zorunludur.
5. Cihazın mevcut konumunu kullanabilir veya enlem ve boylam bilgilerini manuel girebilir.
6. Fotoğraf kullanıcının kendisine ait güvenli depolama yoluna yüklenir.
7. Başlık, açıklama, bildiren kullanıcı, koordinatlar, adres metni, fotoğraf bağlantısı, atık türleri, kirlilik seviyesi ve tarih bilgileriyle kirli bölge kaydı oluşturulur.

Bildirimler giriş yapmış kullanıcılar tarafından listelenebilir. Detay ekranında fotoğraf, koordinat, bildiren kullanıcı, atık türleri, kirlilik seviyesi, durum ve ilgili temizlik etkinlikleri görülebilir.

Konum seçimi için cihaz konumu çalışır durumdadır. “Haritadan seç” işlemi mevcut sürümde etkileşimli harita yerine doğrulanan koordinatların manuel girildiği bir pencere kullanır. Konum seçilmezse uygulama Erzurum merkez koordinatlarını başlangıç değeri olarak kullanabilir; bu nedenle belediye değerlendirmesinde konum doğruluğu ayrıca kontrol edilmelidir.

Fotoğraf analizi için veri alanları ve servis hazırlığı bulunmaktadır. Ancak gerçek yapay zeka bağlantısı yapılmamıştır; mevcut analiz servisi örnek sonuç üretir. Otomatik atık türü tespiti, görüntü doğrulama ve öncelik puanlama işlevleri ileride güvenli bir sunucu veya Firebase tabanlı yapay zeka servisi üzerinden entegre edilebilir.

## 4. Geri Dönüşüm ve Puanlama Sistemi

Geri dönüşüm akışının temel amacı, vatandaşın yaptığı işlemi kayıt altına almak ve düzenli davranışı teşvik etmektir. QR doğrulaması, işlemi tanımlı bir geri dönüşüm noktasıyla ilişkilendirir. Kaydedilen temel bilgiler şunlardır:

- İşlemi yapan kullanıcı
- Atık türü
- Doğrulama yöntemi
- Geri dönüşüm noktası ve konumu
- İşlem tarihi
- Kazanılan puan
- Onay veya inceleme durumu

Fotoğraflı kayıtlar inceleme bekleyen durumda tutulurken QR ile doğrulanan kayıtlar mevcut MVP akışında doğrudan onaylı kabul edilir. Belediye kullanımı için QR noktalarının fiziksel güvenliği, tekrar kullanım kontrolleri ve şüpheli işlem denetimleri ayrıca güçlendirilebilir.

Görev sistemi, tek bir işlem yerine sürekliliği teşvik eder. Örneğin belirli bir atık türünü dönüştürme veya belirli sayıda işlem yapma hedefleri tanımlanabilir. Ödüller ise biriken puanın vatandaş açısından görünür bir karşılığa dönüşmesini sağlar. Belediye, yerel işletmeler veya sosyal destek programlarıyla tanımlanabilecek ödüller bu yapıya eklenebilir.

Puan verme, görev bonusu, ödül kullanımı ve stok azaltma işlemlerinin bir bölümü mevcut MVP'de istemci işlemleriyle yürütülmektedir. Gerçek kullanım öncesinde bu kritik işlemlerin sunucu tarafı doğrulamasıyla korunması gerekir.

## 5. Sosyal Katılım ve Grup Özellikleri

Kullanıcılar ad veya e-posta bilgisiyle diğer kullanıcıları arayabilir ve arkadaşlık isteği gönderebilir. Gelen istekler kabul veya reddedilebilir; gerekli durumda bağlantı engellenebilir. Kabul edilen bağlantılar arkadaş listesinde görüntülenir.

Sosyal ekranlarda gerçek kayıt bulunmadığında uygulamanın tanıtılabilmesi için yerel demo arkadaşlar, istekler ve davetler gösterilebilir. Demo kayıtlar üzerinde veri değiştiren işlemler kapalıdır ve bu kayıtlar belediye verisi olarak değerlendirilmemelidir. Kullanıcı profil detay sayfası da mevcut sürümde henüz bağlı değildir.

Bir kirli bölge için kullanıcı temizlik etkinliği oluşturabilir. Etkinlikte başlık, açıklama, buluşma noktası, tarih ve saat ile azami katılımcı sayısı belirlenir. Diğer kullanıcılar etkinliğe katılabilir veya ayrılabilir. Etkinliği oluşturan kullanıcı, çalışma tamamlandığında kanıt fotoğrafı ve açıklama göndererek belediye ya da yetkili onayına sunabilir.

Etkinlik içinde temizlik grupları oluşturulabilir. Kullanıcı gruba katılabilir, ayrılabilir ve arkadaşlarını davet edebilir. Davet edilen kullanıcı daveti kabul veya reddedebilir. Grup üyeliği etkinliğin katılımcı sayısıyla birlikte güncellenir.

Temizlik kanıtının onaylanması ve katılımcılara puan dağıtılması için admin akışı ve Cloud Functions hazırlığı bulunmaktadır. MVP'deki istemci tabanlı çapraz kayıt işlemleri gerçek belediye kullanımından önce sunucu tarafına taşınmalı ve yetkili personel rolleriyle sınırlandırılmalıdır.

## 6. Belediye Açısından Sağlanan Faydalar

### Konumlu çevre bildirimi alma

Vatandaşlar fotoğraf, koordinat, atık türü, açıklama ve kirlilik seviyesi içeren kayıtlar oluşturabilir. Bu yapı, çağrı merkezi veya sosyal medya üzerinden gelen dağınık bildirimlerin standart alanlarla toplanmasına yardımcı olabilir.

### Saha çalışmalarını önceliklendirme

Kirli bölgenin konumu, kirlilik seviyesi, atık türleri, bildirim tarihi ve katılımcı sayısı birlikte değerlendirilebilir. Aynı bölgede yoğunlaşan kayıtlar, yüksek seviyeli bildirimler veya uzun süre açık kalan sorunlar ileride belediye panelinde önceliklendirilebilir.

### Geri dönüşüm davranışını teşvik etme

QR ile doğrulanan atık kayıtları, görevler, puanlar ve ödüller vatandaşın geri dönüşüm noktalarını daha düzenli kullanmasını teşvik eder. Nokta bazlı kayıtlar hangi tesislerin daha çok kullanıldığını anlamaya katkı sağlayabilir.

### Geri dönüşüm noktalarının durumunu izleme

Vatandaşlar bozuk, dolu, kayıp veya yanlış konumda görünen noktaları bildirebilir. Bu kayıtlar bakım ekiplerinin saha kontrol listesine dönüştürülebilir ve sorunların çözülme süresi izlenebilir.

### Toplumsal katılımı artırma

Arkadaşlık, grup daveti ve temizlik etkinliği özellikleri çevre çalışmalarını bireysel bir işlem olmaktan çıkarıp ortak katılıma dönüştürmeyi amaçlar. Mahalle, okul, kampüs veya gönüllü gruplar için etkinlikler düzenlenebilir.

### Sürdürülebilir kullanım oluşturma

Tek seferlik kampanyalar yerine günlük ve haftalık görevler, dönemsel görevler, sıralama ve ödüller kullanılabilir. Belediye farklı dönemlerde öncelik verdiği atık türlerine veya bölgelere uygun görevler tanımlayabilir.

### Ölçülebilir veri üretme

Uygulama; kullanıcı katılımı, atık kayıtları, kullanılan geri dönüşüm noktaları, bildirim türleri, kirli bölge kayıtları, etkinlik katılımı ve ödül kullanımı gibi başlıklarda yapılandırılmış veri üretebilir. Ancak mevcut projede belediye için tamamlanmış bir raporlama veya karar destek paneli bulunmamaktadır. Bu katkının kurumsal olarak kullanılabilmesi için veri kalitesi, yetkilendirme, raporlama ve kişisel veri politikalarıyla birlikte geliştirilmesi gerekir.

## 7. Veri, Konum ve Fotoğraf Kullanımı

Uygulamada kullanıcı hesabı, geri dönüşüm işlemi, görev ilerlemesi, puan, ödül kullanımı, arkadaşlık, grup, etkinlik ve bildirim kayıtları tutulur. Kirli bölge ve geri dönüşüm işlemlerinde konum bilgisi; fotoğraflı atık kaydı, kirli bölge bildirimi ve temizlik kanıtında ise görsel veri kullanılabilir.

Fotoğraflar Firebase Storage üzerinde kullanıcı veya etkinlik bazlı klasörlerde saklanır. Kirli bölge fotoğrafları için dosya türü görsel olmalı ve boyut 5 MB'ı geçmemelidir. Firestore güvenlik kuralları kullanıcıların yalnızca yetkili oldukları kayıtları yazmasını amaçlar; ortak içeriklerin bir bölümü giriş yapmış kullanıcılara okunabilir durumdadır.

Belediye kullanımına geçmeden önce aşağıdaki konuların kurumsal politika haline getirilmesi gerekir:

- Kullanıcıya açık ve anlaşılır aydınlatma ve açık rıza metinleri
- Konum ve fotoğrafın hangi amaçlarla kullanılacağının belirtilmesi
- Saklama süresi, silme ve anonimleştirme kuralları
- Yetkili belediye personeli için rol bazlı erişim
- Uygunsuz içerik, hatalı konum ve mükerrer bildirim denetimi
- Toplu raporlarda kişisel verilerin ayrıştırılması veya anonimleştirilmesi
- Fotoğraf ve konum doğruluğunun saha kontrolüyle teyit edilmesi

Uygulama vatandaş bildirimi üretir; bildirimin tek başına belediye tarafından doğrulanmış saha tespiti anlamına gelmediği kullanıcı ve personel ekranlarında açıkça belirtilmelidir.

## 8. Geliştirilebilir Alanlar

Mevcut proje yapısında aşağıdaki alanlar geliştirmeye açıktır:

- Belediye personeli için bildirim inceleme, atama, durum güncelleme ve raporlama paneli
- Kirli bölge ve geri dönüşüm noktası bildirimlerinin harita üzerinde yoğunluk analizi
- Mükerrer kayıtların konum ve zaman bilgisiyle birleştirilmesi
- Manuel koordinat girişinin etkileşimli harita üzerinden konum seçimine dönüştürülmesi
- Fotoğrafların uygunsuz içerik ve çevre bildirimi açısından sunucu tarafında doğrulanması
- Yapay zeka ile atık türü, kirlilik düzeyi ve olası mükerrer bildirim analizi
- Barkodların ürün ve atık ayrıştırma bilgisiyle eşleştirilmesi
- Puan, görev, ödül ve grup işlemlerinin tamamının güvenli sunucu servislerine taşınması
- Sıralamaların gerçek veriden otomatik üretilmesi ve kullanıcı gizlilik tercihlerinin uygulanması
- Bildirim, etkinlik hatırlatması ve durum değişikliği için gerçek push bildirimleri
- Belediye ekiplerinin müdahale süresi ve sonuç fotoğrafı gibi operasyon kayıtları
- Erişilebilirlik, çoklu dil ve düşük bağlantı koşulları için çevrim dışı kullanım desteği
- KVKK uyumlu veri saklama, silme, denetim kaydı ve anonim raporlama süreçleri

Bu başlıklar mevcut uygulamanın kesin olarak sunduğu işlevler değil, mevcut veri modeli ve ekran yapısı üzerine eklenebilecek geliştirme alanlarıdır.

## 9. Kısa Sonuç

AtıkAvı Erzurum'un vatandaş tarafındaki mevcut yapısı; kullanıcı hesabı, QR ve fotoğrafla atık kaydı, geri dönüşüm noktası haritası, kirli bölge bildirimi, görev ve puan takibi, ödül kullanımı, sosyal bağlantılar ve gönüllü temizlik etkinliklerini tek uygulamada bir araya getirir.

Belediye açısından en önemli potansiyel katkı, vatandaş katılımını standart ve konumlu kayıtlar üzerinden görünür hale getirmesidir. Uygulama mevcut haliyle işlevsel bir MVP ve sunum altyapısıdır. Kurumsal kullanıma geçiş için belediye yönetim paneli, sunucu tarafı doğrulama, operasyon süreçleri, veri analizi ve KVKK uygulamalarının tamamlanması gerekir.
