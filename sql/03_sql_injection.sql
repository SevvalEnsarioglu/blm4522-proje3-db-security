-- =============================================
-- ADIM 3: SQL INJECTION TESTLERİ
-- Amaç: Savunmasız sorgular ile saldırıları simüle edelim ve Prepared Statements ile korunalım.
-- =============================================

-- 1. Savunmasız Sorgu Simülasyonu Yapalım (Dinamik SQL)
-- Kullanıcıdan gelen girişi doğrudan string birleştirme ile sorguya eklemek tehlikelidir.
DO $$
DECLARE
    kullanici_girisi TEXT := ''' OR ''1''=''1'; -- Saldırgan girişi
    sorgu TEXT;
BEGIN
    sorgu := 'SELECT * FROM customer WHERE email = ''' || kullanici_girisi || '''';
    RAISE NOTICE 'Potansiyel tehlikeli sorgu: %', sorgu;
END $$;

-- 2. Injection Senaryosu: Her Zaman True Döndüren Giriş Yapalım
-- Beklenen: Tek bir email araması. Sonuç: Tüm tablo dökümü.
SELECT * FROM customer
WHERE email = '' OR '1'='1' --';

-- 3. KORUMALI YÖNTEM: Prepared Statements Kullanalım
-- Sorgu bir kez hazırlanır, parametreler dışarıdan güvenli bir şekilde aktarılır.
PREPARE guvenli_sorgu(TEXT) AS
    SELECT customer_id, first_name, last_name, email
    FROM customer
    WHERE email = $1;

-- Normal Kullanım yapalım
EXECUTE guvenli_sorgu('mary.smith@sakilacustomer.org');

-- Injection Denemesi yapalım (Zararsız: Sonuç dönmez çünkü literal olarak o metni arar)
EXECUTE guvenli_sorgu(''' OR ''1''=''1');

-- Temizlik yapalım
DEALLOCATE guvenli_sorgu;

-- 4. EK GÜVENLİK: View'lar Üzerinden Kısıtlı Erişim Sağlayalım
-- Hassas tabloların direkt erişimini kapatıp sadece gerekli alanları içeren View oluşturalım.
REVOKE ALL ON customer FROM PUBLIC;

CREATE VIEW musteri_gorunum AS
SELECT customer_id, first_name, last_name, active
FROM customer; -- Email ve hassas adres bilgileri View'a dahil edilmedi.

GRANT SELECT ON musteri_gorunum TO readonly_user;
