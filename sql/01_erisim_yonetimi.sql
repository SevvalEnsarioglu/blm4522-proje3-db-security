-- =============================================
-- ADIM 1: ERİŞİM YÖNETİMİ (Authentication & Authorization)
-- MSSQL Karşılıkları: SQL Server Authentication & Windows Authentication
-- =============================================

-- 1. Mevcut rolleri ve yetkilerini kontrol edelim
SELECT rolname, rolcanlogin, rolsuper, rolcreatedb
FROM pg_roles
WHERE rolname NOT LIKE 'pg_%'
ORDER BY rolname;

-- 2. Şifre politikası ve geçerlilik süresi ile yeni roller oluşturalım
-- SQL Server Authentication karşılığı
CREATE ROLE guvenlik_test LOGIN PASSWORD 'Gv3nl!kT3st#2026'
  VALID UNTIL '2027-01-01';

-- 3. Belirli bir veritabanı ve sema için kısıtlı yetkili kullanıcı oluşturalım
CREATE ROLE readonly_user LOGIN PASSWORD 'R3ad0nly!2026';
GRANT CONNECT ON DATABASE dvdrental TO readonly_user;
GRANT USAGE ON SCHEMA public TO readonly_user;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly_user;

-- 4. Kullanıcının güncel yetkilerini listeleyelim
SELECT grantee, table_name, privilege_type
FROM information_schema.role_table_grants
WHERE grantee = 'readonly_user'
ORDER BY table_name;

-- 5. Yetkiyi geri alma (REVOKE) işlemi yapalım
-- Senaryo: readonly_user'ın customer tablosuna erişimini keselim
REVOKE SELECT ON customer FROM readonly_user;

-- 6. Test edelim (Hata vermesi beklenir)
/*
SET ROLE readonly_user;
SELECT * FROM customer LIMIT 5; -- ERROR: permission denied for table customer
RESET ROLE;
*/

-- NOTE: Windows Authentication karşılığı olan host tabanlı erişim kontrolü
-- pg_hba.conf dosyası üzerinden yapılır. Örnek yapılandırma:
-- host    dvdrental   readonly_user 127.0.0.1/32  md5
