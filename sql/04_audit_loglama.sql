-- =============================================
-- ADIM 4: AUDIT LOGLAMA (Denetim Kayıtları)
-- MSSQL Karşılığı: SQL Server Audit
-- =============================================

-- 1. PostgreSQL Dahili Log Ayarlarını Kontrol Edelim
SHOW log_statement;
SHOW log_connections;
SHOW log_disconnections;

-- Oturum bazlı tüm sorguları loglayalım (Test amaçlı)
SET log_statement = 'all';

-- 2. Özel Audit Log Tablosu Oluşturalım
-- pgaudit kurulumu yapılamayan ortamlarda manuel tetikleyici (trigger) bazlı loglama yapalım.
CREATE TABLE audit_log (
    log_id SERIAL PRIMARY KEY,
    kullanici TEXT DEFAULT current_user,
    islem_tipi TEXT,
    tablo_adi TEXT,
    eski_deger JSONB,
    yeni_deger JSONB,
    islem_zamani TIMESTAMP DEFAULT NOW(),
    ip_adresi TEXT DEFAULT inet_client_addr()::TEXT
);

-- 3. Audit Trigger Fonksiyonunu Tanımlayalım
-- Bu fonksiyon her türlü INSERT, UPDATE ve DELETE işlemini detaylıca kaydeder.
CREATE OR REPLACE FUNCTION audit_trigger_func()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit_log(islem_tipi, tablo_adi, yeni_deger)
        VALUES ('INSERT', TG_TABLE_NAME, row_to_json(NEW)::JSONB);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit_log(islem_tipi, tablo_adi, eski_deger, yeni_deger)
        VALUES ('UPDATE', TG_TABLE_NAME, 
                row_to_json(OLD)::JSONB, row_to_json(NEW)::JSONB);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit_log(islem_tipi, tablo_adi, eski_deger)
        VALUES ('DELETE', TG_TABLE_NAME, row_to_json(OLD)::JSONB);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. Tetikleyicileri (Triggers) Tablolara Bağlayalım
-- Customer tablosu denetimi yapalım
CREATE TRIGGER customer_audit
AFTER INSERT OR UPDATE OR DELETE ON customer
FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

-- Payment tablosu denetimi yapalım
CREATE TRIGGER payment_audit
AFTER INSERT OR UPDATE OR DELETE ON payment
FOR EACH ROW EXECUTE FUNCTION audit_trigger_func();

-- 5. Audit Loglama Testi Yapalım
-- Veri güncelleme işlemi yapalım
UPDATE customer SET active = 0 WHERE customer_id = 1;
UPDATE customer SET active = 1 WHERE customer_id = 1;

-- Logları inceleyelim
SELECT log_id, kullanici, islem_tipi, tablo_adi, 
       islem_zamani, yeni_deger 
FROM audit_log 
ORDER BY islem_zamani DESC;
