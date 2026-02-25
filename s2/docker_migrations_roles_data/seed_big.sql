TRUNCATE TABLE client_order_status_log, client_order_services, client_order_items, client_order RESTART IDENTITY CASCADE;
TRUNCATE TABLE product_prices, nomenclature, service_prices, service, employee, client, car, car_model, supplier, location RESTART IDENTITY CASCADE;

INSERT INTO location(address, phone_number, working_hours, coordinates)
SELECT
  'Address ' || gs::text,
  '+7' || (9000000000 + gs)::text,
  '09:00-21:00',
  point((random()*180 - 90), (random()*360 - 180))
FROM generate_series(1, 50) gs;

INSERT INTO supplier(company_name, phone_number, email, bank_account)
SELECT
  'Supplier ' || gs::text,
  '+7' || (9100000000 + gs)::text,
  CASE WHEN random() < 0.15 THEN NULL ELSE ('sup' || gs::text || '@mail.test') END,
  lpad((10000000000000000000::bigint + gs)::text, 20, '0')
FROM generate_series(1, 100) gs;

INSERT INTO car_model(model_name, brand_name)
SELECT
  'Model-' || gs::text,
  (ARRAY['Toyota','Kia','Hyundai','VW','BMW','Audi','Lada','Renault','Ford','Skoda','Nissan','Honda','Mazda','Chevrolet','Geely','Chery','Haval','Mercedes','Opel','Peugeot'])[1 + (random()*19)::int]
FROM generate_series(1, 200) gs;

INSERT INTO client(full_name, phone_number, email, driver_license)
SELECT
  'Client ' || gs::text,
  '+7' || (9200000000 + (gs % 99999999))::text,
  CASE WHEN random() < 0.12 THEN NULL ELSE ('c' || gs::text || '@mail.test') END,
  CASE WHEN random() < 0.10 THEN NULL ELSE ('DL' || gs::text) END
FROM generate_series(1, 50000) gs;

INSERT INTO car(vin, year, license_plate, color, model_id)
SELECT
  substr(encode(gen_random_bytes(16), 'hex'), 1, 17),
  1990 + (random()*35)::int,
  CASE WHEN random() < 0.20 THEN NULL ELSE ('A' || (1000 + (gs % 9000))::text || 'BC') END,
  (ARRAY['black','white','silver','blue','red','gray'])[1 + (random()*5)::int],
  1 + (random()*199)::int
FROM generate_series(1, 200000) gs;

INSERT INTO employee(position, location_id, status, full_name, phone_number, hire_date)
SELECT
  (ARRAY['mechanic','manager','cashier','admin'])[1 + (random()*3)::int],
  1 + (random()*49)::int,
  (ARRAY['работает','уволен','отпуск'])[1 + (random()*2)::int]::employee_status,
  'Employee ' || gs::text,
  '+7' || (9300000000 + (gs % 99999999))::text,
  (CURRENT_DATE - ((random()*2000)::int))
FROM generate_series(1, 500) gs;

INSERT INTO service(name, base_price, lead_time)
SELECT
  'SVC-' || gs::text,
  500 + (random()*50000)::int,
  10 + (random()*240)::int
FROM generate_series(1, 300) gs;

INSERT INTO service_prices(service_name, price, effective_date)
SELECT
  s.name,
  s.base_price + (random()*5000)::int,
  CURRENT_DATE
FROM service s;

INSERT INTO nomenclature(article, name, id_supplier)
SELECT
  'ART-' || gs::text,
  'Product ' || gs::text,
  1 + (random()*99)::int
FROM generate_series(1, 2000) gs;

INSERT INTO product_prices(article, price, effective_date)
SELECT
  n.article,
  100 + (random()*20000)::int,
  CURRENT_DATE
FROM nomenclature n;

INSERT INTO client_order(id_client, id_car, id_location, employee_id, created_date, total_amount, status, completion_date, notes, priority, work_period, tags, meta, external_id)
SELECT
  1 + (random()*49999)::int,
  1 + (random()*199999)::int,
  1 + (random()*49)::int,
  CASE WHEN random() < 0.70 THEN 1 + (random()*49)::int ELSE 50 + (random()*449)::int END,
  ts,
  (50 + random()*200000)::int,
  (ARRAY['создан','в работе','выполнен','отменен'])[1 + (random()*3)::int]::order_status,
  CASE WHEN random() < 0.15 THEN NULL ELSE ts + (random()*interval '5 days') END,
  CASE WHEN random() < 0.10 THEN NULL ELSE ('note ' || md5(gs::text) || ' oil brake engine') END,
  (ARRAY['низкий','обычный','высокий','срочный'])[1 + (random()*3)::int]::order_priority,
  tsrange(ts, ts + (random()*interval '5 days'), '[]'),
  ARRAY[(ARRAY['urgent','repeat','vip','warranty','diagnostic'])[1 + (random()*4)::int]],
  CASE WHEN random() < 0.15 THEN NULL ELSE jsonb_build_object('source', (ARRAY['web','phone','walkin','partner'])[1 + (random()*3)::int], 'score', (random()*100)::int) END,
  gen_random_uuid()
FROM (
  SELECT gs, (now() - (random() * interval '365 days')) AS ts
  FROM generate_series(1, 250000) gs
) t;

INSERT INTO client_order_items(id_order, product_price_id, quantity, unit_price, meta, comment)
SELECT
  1 + (random()*249999)::int,
  CASE WHEN random() < 0.60 THEN 1 + (random()*49)::int ELSE 50 + (random()*1949)::int END,
  1 + (random()*5)::int,
  100 + (random()*20000)::int,
  CASE WHEN random() < 0.15 THEN NULL ELSE jsonb_build_object('warehouse', (ARRAY['A','B','C','D'])[1 + (random()*3)::int], 'promo', (random()<0.1)) END,
  CASE WHEN random() < 0.10 THEN NULL ELSE ('item ' || md5(gs::text)) END
FROM generate_series(1, 250000) gs;

INSERT INTO client_order_services(id_order, service_price_id, quantity, unit_price, meta)
SELECT
  1 + (random()*249999)::int,
  CASE WHEN random() < 0.55 THEN 1 + (random()*19)::int ELSE 20 + (random()*279)::int END,
  1 + (random()*3)::int,
  500 + (random()*50000)::int,
  CASE WHEN random() < 0.15 THEN NULL ELSE jsonb_build_object('tool', (ARRAY['lift','scanner','hand','lathe'])[1 + (random()*3)::int]) END
FROM generate_series(1, 250000) gs;

INSERT INTO client_order_status_log(order_id, status, changed_at)
SELECT
  1 + (random()*249999)::int,
  (ARRAY['создан','в работе','выполнен','отменен'])[1 + (random()*3)::int]::order_status,
  now() - (random() * interval '365 days')
FROM generate_series(1, 250000);