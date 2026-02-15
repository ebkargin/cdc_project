# SQL Server to MongoDB CDC (Change Data Capture) Service

Bu proje, SQL Server üzerindeki `Orders` tablosunda meydana gelen değişiklikleri (Insert, Update, Delete) bir log tablosu üzerinden takip ederek **MongoDB**'ye asenkron olarak aktaran bir veri senkronizasyon servisidir.

## 🚀 Proje Amacı
İlişkisel veritabanındaki (SQL Server) kritik veri değişimlerini, analiz veya hızlı sorgulama amacıyla doküman tabanlı bir yapıya (MongoDB) gerçek zamanlıya yakın bir şekilde taşımaktır.

## 🛠️ Kullanılan Teknolojiler
* **Python 3.x**
* **SQL Server (T-SQL):** Kaynak veritabanı.
* **MongoDB:** Hedef veri deposu.
* **PyODBC:** SQL Server bağlantısı için kullanılan kütüphane.
* **PyMongo:** MongoDB entegrasyonu için kullanılan kütüphane.

## 📋 Veritabanı Gereksinimleri
Servisin çalışabilmesi için SQL Server tarafında bir `Orders_log` tablosunun bulunması ve bu tablonun işlenme durumunu belirten `is_processed` bayrağını içermesi gerekmektedir. 

## ⚙️ Kurulum ve Çalıştırma

### 1. Bağımlılıkları Yükleyin
Sistemin çalışması için gerekli Python kütüphanelerini aşağıdaki komutla yükleyebilirsiniz:
```bash
pip install pyodbc pymongo
```

### 3. Servisi Başlatın
Tüm ayarlar tamamlandıktan sonra terminal üzerinden servisi ayağa kaldırın:

```bash
python main.py
```

## 🔄 Çalışma Mantığı ve Mimari
1. **Polling:** `main.py` içerisindeki sonsuz döngü, her 5 saniyede bir `process_logs()` fonksiyonunu tetikler.
2. **Yakalama (Capture):** `Orders_log` tablosunda henüz işlenmemiş (`is_processed = 0`) olan tüm kayıtlar `changed_at` sırasına göre SQL Server'dan çekilir.
3. **Dönüştürme (Mapping):** Çekilen satır verileri, MongoDB'nin esnek doküman yapısına uygun bir JSON objesine dönüştürülür. Eski veriler `old`, güncel veriler ise `new` anahtarı altında gruplanır.
4. **Yükleme (Load):** Hazırlanan dokümanlar MongoDB'deki `cdc_logs` veritabanına kaydedilir.
5. **İşaretleme (Update):** Aktarımı başarıyla tamamlanan her kayıt, SQL tarafında tekrar işlenmemesi için `is_processed = 1` olarak güncellenir.

## 📁 Proje Dosya Yapısı
* **`main.py`**: Uygulamanın giriş noktası ve döngü yönetimi.
* **`cdc_service.py`**: Veri işleme, dönüşüm ve SQL-NoSQL arası mantıksal akış.
* **`db.py`**: SQL Server bağlantı konfigürasyonu.
* **`mongo.py`**: MongoDB bağlantı konfigürasyonu.

---
**Geliştiren:** [Ertuğrul Berk Kargın](https://github.com/ebkargin)
