# Proje 3: Veritabanı Güvenliği (PostgreSQL)

Bu proje, veritabanı güvenliği kapsamındaki temel tekniklerin PostgreSQL üzerinde nasıl uygulanacağını, MSSQL'deki karşılıklarıyla kıyaslayarak ele almaktadır.

## MSSQL vs PostgreSQL Karşılaştırma Tablosu

| Özellik | MSSQL                             | PostgreSQL                              |
| :--- |:----------------------------------|:----------------------------------------|
| **Kimlik Doğrulama** | SQL Server Authentication         | PostgreSQL LOGIN ROLE + Şifre           |
| **Erişim Kontrolü** | Windows Authentication            | `pg_hba.conf` ile Host Tabanlı Erişim   |
| **Veri Şifreleme** | TDE (Transparent Data Encryption) | `pgcrypto` ile Sütun Bazlı Şifreleme    |
| **Injection Koruması** | SQL Injection Koruması            | Prepared Statements + Güvenlik Testleri |
| **Denetim** | SQL Server Audit                  | `pgaudit` / Trigger Bazlı Custom Audit  |

## Proje Yapısı

- **`sql/`**: Güvenlik senaryolarının SQL kodları.
  - `01_erisim_yonetimi.sql`: Kullanıcı rolleri, şifre politikaları ve yetki (GRANT/REVOKE) yönetimi.
  - `02_veri_sifreleme.sql`: `pgcrypto` ile hassas verilerin simetrik şifrelenmesi.
  - `03_sql_injection.sql`: Injection saldırı simülasyonları ve Prepared Statements ile korunma.
  - `04_audit_loglama.sql`: Trigger tabanlı detaylı işlem denetimi.
- **`rapor/`**: Uygulama raporlarını içerir.
- **`ekran_goruntuleri/`**: Yapılan testlerin çıktıları ve kanıtları.

## Öne Çıkan Güvenlik Teknikleri

### 1. Erişim Yönetimi
Kullanıcılara sadece "En Az Yetki" (Least Privilege) prensibiyle erişim tanımlanmış, şifrelerin geçerlilik süreleri ve bağlanabilecekleri IP adresleri (`pg_hba.conf`) kısıtlanmıştır.

### 2. Sütun Bazlı Şifreleme
Kredi kartı ve email gibi hassas veriler veritabanında açık metin olarak değil, `pgp_sym_encrypt` fonksiyonu ile şifrelenmiş byte dizileri olarak saklanır. Doğru anahtar olmadan veri deşifre edilemez.

### 3. Prepared Statements
Dinamik SQL yapılarından kaçınılarak sorgular önceden derlenmiş (prepare) hale getirilmiş, böylece SQL Injection saldırıları tamamen engellenmiştir.

### 4. Gelişmiş Audit Sistemi
Sistemin dahili loglama mekanizmasına ek olarak, hangi kullanıcının, hangi tablodaki hangi veriyi, ne zaman ve hangi IP'den değiştirdiğini JSON formatında kaydeden özel bir trigger tabanlı denetim sistemi kurulmuştur.
