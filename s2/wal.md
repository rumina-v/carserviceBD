# WAL/LSN, дампы и идемпотентные seed 

---

## 1. Сравнение LSN до/после INSERT 

```sql
\set ON_ERROR_STOP on

SELECT pg_current_wal_lsn() AS lsn_before_insert \gset

INSERT INTO client (id, full_name, phone_number, email, driver_license)
VALUES
  (1001,'WAL Demo 1','+79990000001','wal_demo1@example.com','WAL001'),
  (1002,'WAL Demo 2','+79990000002','wal_demo2@example.com','WAL002')
ON CONFLICT (driver_license) DO UPDATE
  SET full_name = EXCLUDED.full_name,
      phone_number = EXCLUDED.phone_number,
      email = EXCLUDED.email;

SELECT pg_current_wal_lsn() AS lsn_after_insert \gset
SELECT :'lsn_before_insert' AS lsn_before_insert,
       :'lsn_after_insert'  AS lsn_after_insert,
       pg_wal_lsn_diff(:'lsn_after_insert', :'lsn_before_insert') AS wal_bytes_for_insert;
```

## 2. WAL до и после COMMIT

```sql
BEGIN;
SELECT pg_current_wal_lsn() AS lsn_tx_begin \gset

INSERT INTO client (id, full_name, phone_number, email, driver_license)
VALUES (1003,'WAL Demo 3','+79990000003','wal_demo3@example.com','WAL003')
ON CONFLICT (driver_license) DO UPDATE
  SET full_name = EXCLUDED.full_name,
      phone_number = EXCLUDED.phone_number,
      email = EXCLUDED.email;

SELECT pg_current_wal_lsn() AS lsn_after_tx_insert \gset
COMMIT;
SELECT pg_current_wal_lsn() AS lsn_after_commit \gset

SELECT pg_wal_lsn_diff(:'lsn_after_tx_insert', :'lsn_tx_begin')   AS wal_bytes_inside_tx,
       pg_wal_lsn_diff(:'lsn_after_commit', :'lsn_after_tx_insert') AS wal_bytes_commit_only;
```

## 3. Массовая операция и объём WAL

```sql
SELECT pg_current_wal_insert_lsn() AS lsn_bulk_before \gset

CREATE TEMP TABLE wal_bulk_tmp(id int PRIMARY KEY, payload text);
INSERT INTO wal_bulk_tmp
SELECT g, md5(g::text)
FROM generate_series(1,20000) g;

SELECT pg_current_wal_insert_lsn() AS lsn_bulk_after \gset
SELECT pg_wal_lsn_diff(:'lsn_bulk_after', :'lsn_bulk_before') AS wal_bytes_bulk,
       round(pg_wal_lsn_diff(:'lsn_bulk_after', :'lsn_bulk_before')/1024/1024, 2) AS wal_mb_bulk;

DROP TABLE wal_bulk_tmp;
```

Подсказка: накопленные счётчики WAL можно посмотреть через  
```sql
SELECT wal_records, wal_fpi, wal_bytes FROM pg_stat_wal;
```

## 4. Команды для дампов (выполнять в хост-шелле, контейнер carservice_postgres)

```bash
# Полный дамп (формат custom)
docker exec carservice_postgres pg_dump -U admin -d carservice_db -F c -f /tmp/carservice.backup
docker cp carservice_postgres:/tmp/carservice.backup ./carservice.backup

# Восстановление в новую чистую БД
docker exec carservice_postgres createdb -U admin carservice_db_clone
docker exec carservice_postgres pg_restore -U admin -d carservice_db_clone /tmp/carservice.backup

# Только структура
docker exec carservice_postgres pg_dump -U admin -d carservice_db -s -f /tmp/carservice_schema.sql

# Только одна таблица (пример public.client)
docker exec carservice_postgres pg_dump -U admin -d carservice_db -t public.client -f /tmp/client.sql
```

## 5. Идемпотентные seed тестовых данных (ON CONFLICT)

```sql
-- Модели автомобилей
INSERT INTO car_model (id, model_name, brand_name) VALUES
  (1001,'Octavia','Skoda'),
  (1002,'CX-5','Mazda')
ON CONFLICT (id) DO UPDATE
  SET model_name = EXCLUDED.model_name,
      brand_name = EXCLUDED.brand_name;

-- Клиенты
INSERT INTO client (id, full_name, phone_number, email, driver_license) VALUES
  (1001,'WAL Demo 1','+79990000001','wal_demo1@example.com','WAL001'),
  (1002,'WAL Demo 2','+79990000002','wal_demo2@example.com','WAL002'),
  (1003,'WAL Demo 3','+79990000003','wal_demo3@example.com','WAL003')
ON CONFLICT (driver_license) DO UPDATE SET
  full_name     = EXCLUDED.full_name,
  phone_number  = EXCLUDED.phone_number,
  email         = EXCLUDED.email;

-- Машины и связь с клиентами
INSERT INTO car (id, vin, year, license_plate, color, model_id) VALUES
  (2001,'TMPWALVIN0000001',2021,'A123BC77','Gray',1001),
  (2002,'TMPWALVIN0000002',2022,'A456BC77','Red',1002)
ON CONFLICT (vin) DO UPDATE SET
  year          = EXCLUDED.year,
  license_plate = EXCLUDED.license_plate,
  color         = EXCLUDED.color,
  model_id      = EXCLUDED.model_id;

INSERT INTO car_client (car_id, client_id) VALUES
  (2001,1001),
  (2002,1002)
ON CONFLICT DO NOTHING;

-- Услуги и прайс
INSERT INTO service (name, base_price, lead_time) VALUES
  ('Диагностика подвески', 3500, 60),
  ('Замена свечей',        2800, 45)
ON CONFLICT (name) DO UPDATE SET
  base_price = EXCLUDED.base_price,
  lead_time  = EXCLUDED.lead_time;

INSERT INTO service_prices (service_name, price, effective_date) VALUES
  ('Диагностика подвески', 3500, CURRENT_DATE),
  ('Замена свечей',        2800, CURRENT_DATE)
ON CONFLICT (service_name, effective_date) DO UPDATE SET
  price = EXCLUDED.price;

-- Подправляем последовательности
SELECT setval('car_model_id_seq', COALESCE((SELECT max(id) FROM car_model), 1), true);
SELECT setval('client_id_seq',    COALESCE((SELECT max(id) FROM client), 1), true);
SELECT setval('car_id_seq',       COALESCE((SELECT max(id) FROM car), 1), true);
```
