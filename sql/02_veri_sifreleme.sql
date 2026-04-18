-- =============================================
-- ADIM 2: VERİ ŞİFRELEME (Data Encryption)
-- MSSQL Karşılığı: TDE (Transparent Data Encryption) benzeri sütun bazlı şifreleme
-- =============================================

-- 1. pgcrypto eklentisini aktif edelim (Sütun bazlı şifreleme için gereklidir)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 2. Hassas veri içeren test tablosu oluşturalım
CREATE TABLE musteri_hassas (
    id SERIAL PRIMARY KEY,
    ad VARCHAR(100),
    email TEXT,
    email_sifrelenmis BYTEA,
    kredi_karti TEXT,
    kredi_karti_sifrelenmis BYTEA,
    kayit_tarihi TIMESTAMP DEFAULT NOW()
);

-- 3. Veriyi şifreleyelim ve tabloya ekleyelim (Simetrik Şifreleme)
-- 'gizli_anahtar_2026' veriyi şifrelemek ve çözmek için gereken paroladır.
INSERT INTO musteri_hassas (ad, email, email_sifrelenmis, kredi_karti, kredi_karti_sifrelenmis)
VALUES (
    'Ahmet Yılmaz',
    'ahmet@example.com',
    pgp_sym_encrypt('ahmet@example.com', 'gizli_anahtar_2026'),
    '4111-1111-1111-1111',
    pgp_sym_encrypt('4111-1111-1111-1111', 'gizli_anahtar_2026')
),
(
    'Ayşe Kaya',
    'ayse@example.com',
    pgp_sym_encrypt('ayse@example.com', 'gizli_anahtar_2026'),
    '5500-0000-0000-0004',
    pgp_sym_encrypt('5500-0000-0000-0004', 'gizli_anahtar_2026')
);

-- 4. Şifreli veriyi görüntüleyelim (Ham hali anlamsız byte serisidir)
SELECT id, ad, email_sifrelenmis, kredi_karti_sifrelenmis
FROM musteri_hassas;

-- 5. Doğru anahtar ile veriyi çözelim (Deşifre edelim)
SELECT id, ad,
    pgp_sym_decrypt(email_sifrelenmis, 'gizli_anahtar_2026') AS email_acik,
    pgp_sym_decrypt(kredi_karti_sifrelenmis, 'gizli_anahtar_2026') AS kart_acik
FROM musteri_hassas;

-- 6. Yanlış anahtar ile deneme yapalım (Hata vermesi beklenir)
-- SELECT pgp_sym_decrypt(email_sifrelenmis, 'yanlis_anahtar') FROM musteri_hassas LIMIT 1;
