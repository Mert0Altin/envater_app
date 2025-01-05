# Zenity Tabanlı Envanter Uygulaması
youtube linki: https://youtu.be/q4w01Lh7dpc
Bu proje, Linux üzerinde Zenity kullanılarak oluşturulmuş bir envanter yönetim sistemidir. Uygulama, ürün ekleme, listeleme, güncelleme, silme, raporlama ve kullanıcı yönetimi gibi özellikler sunar. Kullanıcı rolleri sayesinde yetkilendirme işlemleri yapılabilir.

---

## Özellikler

### Ana Menü
Uygulama açıldığında kullanıcı şu işlemleri yapabilir:
- **Ürün Ekle**
- **Ürün Listele**
- **Ürün Güncelle**
- **Ürün Sil**
- **Rapor Al**
  - Stokta Azalan Ürünler
  - En Yüksek Stok Miktarına Sahip Ürünler
- **Kullanıcı Yönetimi**
  - Yeni Kullanıcı Ekle
  - Kullanıcıları Listele
  - Kullanıcı Güncelle
  - Kullanıcı Silme
- **Program Yönetimi**
  - Diskteki Alanı Göster
  - Diske Yedekle
  - Hata Kayıtlarını Göster
- **Çıkış**

---

## Kullanıcı Rolleri

1. **Yönetici**:
   - Ürün ekleme, güncelleme, silme ve kullanıcı yönetimi yapabilir.

2. **Kullanıcı**:
   - Sadece ürünleri görüntüleyebilir ve rapor alabilir.

3. **Yetki Hatası**:
   - Yetkisi olmayan bir işlem yapılmaya çalışıldığında uyarı mesajı gösterilir ve kullanıcı ana menüye yönlendirilir.

---

## Fonksiyonlar

### Ürün Yönetimi
- **Ürün Ekle**:
  - Ürün numarası otomatik artarak atanır ve eşsizdir.
  - Zenity ile kullanıcıdan ürün bilgileri alınır ve `depo.csv` dosyasına kaydedilir.
  - Aynı isimde ürün eklenmek istenirse hata mesajı verilerek işlem iptal edilir ve log dosyasına kaydedilir.

- **Ürün Listele**:
  - `depo.csv` dosyasından veriler okunur ve Zenity kullanılarak listelenir.

- **Ürün Güncelle**:
  - Güncellenecek ürün adı kullanıcıdan alınır.
  - İlgili ürün bulunursa stok veya fiyat bilgileri güncellenir.

- **Ürün Sil**:
  - Silinecek ürün adı kullanıcıdan alınır.
  - İlgili ürün `depo.csv` dosyasından kaldırılır.

### Raporlama
- **Stokta Azalan Ürünler**:
  - Kullanıcıdan bir eşik değeri alınır.
  - Bu değerin altındaki stok miktarına sahip ürünler listelenir.

- **En Yüksek Stok Miktarına Sahip Ürünler**:
  - Kullanıcıdan bir eşik değeri alınır.
  - Bu değerin üstünde stok miktarına sahip ürünler listelenir.

### Kullanıcı Yönetimi
- **Yeni Kullanıcı Ekle**:
  - Kullanıcı adı ve şifre alınıp `kullanici.csv` dosyasına kaydedilir.
  - Sadece yöneticiler yeni kullanıcı ekleyebilir.

- **Kullanıcı Listele**:
  - `kullanici.csv` dosyasındaki tüm kullanıcılar Zenity ile listelenir.

- **Kullanıcı Güncelle**:
  - Güncellenecek kullanıcının adı alınır ve bilgileri güncellenir.

- **Kullanıcı Sil**:
  - Silinecek kullanıcının adı alınır ve kayıt `kullanici.csv` dosyasından kaldırılır.

### Program Yönetimi
- **Diskteki Alanı Göster**:
  - `depo.csv`, `kullanici.csv`, `log.csv` ve script dosyasının disk üzerindeki boyutları hesaplanır ve gösterilir.

- **Diske Yedekle**:
  - `depo.csv` ve `kullanici.csv` dosyaları `yedek` adlı bir klasöre yedeklenir.

- **Hata Kayıtlarını Göster**:
  - `log.csv` dosyasındaki hata kayıtları görüntülenir.

---

## Dosya Yapısı

- **depo.csv**: Ürün bilgilerini saklayan dosya.
- **kullanici.csv**: Kullanıcı bilgilerini saklayan dosya.
- **log.csv**: Hata ve işlem kayıtlarını tutar.
- **yedek/**: Yedekleme klasörü.

---

## Kullanım

1. Terminali açın ve script dosyasını çalıştırın:
   ```bash
   bash envanter_uygulamasi.sh
   ```

2. Giriş yapın veya kullanıcı oluşturun.

3. Menü üzerinden işlemlerinizi gerçekleştirin.

---

## Gereksinimler

- Linux işletim sistemi.
- Zenity yüklü olmalıdır:
  ```bash
  sudo apt install zenity
  ```

---

## Notlar

- Uygulama üzerinde yönetici yetkisine sahip kullanıcılar tüm işlemleri gerçekleştirebilir.
- Yetkisiz kullanıcılar yalnızca görüntüleme ve raporlama yapabilir.
- Log dosyasında hata kayıtları tutulur.
