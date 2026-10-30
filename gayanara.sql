create database ecommerce_gayanara;
use ecommerce_gayanara;

-- Hapus transaksi 2025 karena hanya menggunakan transaksi 2022 - 2024
SET SQL_SAFE_UPDATES = 0;
BEGIN;   -- SQL Server: BEGIN TRANSACTION;  MySQL: START TRANSACTION;

DELETE FROM order_items
WHERE order_id IN (
    SELECT order_id FROM orders WHERE order_date >= '2025-01-01'
);

DELETE FROM orders
WHERE order_date >= '2025-01-01';

SELECT COUNT(*) FROM orders;        
SELECT COUNT(*) FROM order_items;   

COMMIT;

SET SQL_SAFE_UPDATES = 1;


-- Inkonsistensi Data Category
SELECT
    category,
    CASE
        WHEN LOWER(TRIM(category)) IN ('accessories', 'aksesoris')
            THEN 'Aksesoris'
        WHEN LOWER(TRIM(category)) IN ('pants', 'celana')
            THEN 'Celana'
        WHEN LOWER(TRIM(category)) = 'dress'
            THEN 'Dress'
        WHEN LOWER(TRIM(category)) IN ('jacket', 'jaket')
            THEN 'Jaket'
        WHEN LOWER(TRIM(category)) IN ('t-shirt', 'kaos')
            THEN 'Kaos'
        WHEN LOWER(TRIM(category)) IN ('kemeja', 'shirt')
            THEN 'Kemeja'
        ELSE TRIM(category)
    END AS category_bersih
FROM products;

-- Menangani Missing Values
SELECT
    customer_id,
    name,
    phone,
    COALESCE(NULLIF(TRIM(phone), ''), 'Tidak Diketahui') AS phone_bersih
FROM customers;

SELECT
    order_id,
    discount_amount_idr,
    COALESCE(discount_amount_idr, 0) AS discount_amount_bersih
FROM orders;

SELECT
    order_id,
    promo_code,
    COALESCE(NULLIF(TRIM(promo_code), ''), 'Tanpa Promo')
        AS promo_code_bersih
FROM orders;

SELECT
    product_id,
    name,
    material,
    COALESCE(NULLIF(TRIM(material), ''), 'Tidak Diketahui')
        AS material_bersih
FROM products;

-- Standarisasi format teks
SELECT
    customer_id,
    name,
    TRIM(name) AS name_bersih,
    city,
    TRIM(city) AS city_bersih
FROM customers;

-- Memperbaiki format nomor telepon
SELECT
    customer_id,
    phone,
    CASE
        WHEN phone IS NULL THEN 'Tidak Diketahui'
        WHEN TRIM(phone) = '' THEN 'Tidak Diketahui'
        WHEN phone LIKE '8%' THEN CONCAT('0', phone)
        ELSE phone
    END AS phone_bersih
FROM customers;

-- JOIN
-- customer sama orders
select c.name
from customers c
join orders o on c.customer_id = o.customer_id;

-- orders sama order_items
select o.order_status
from order_items oi
join orders o on o.order_id = oi.order_id;

-- product sama order_items
select p.name
from order_items oi
join products p on p.product_id = oi.product_id;
