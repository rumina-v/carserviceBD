INSERT INTO client (full_name, phone_number, email, driver_license)
SELECT
    'Client ' || g,
    '+79' || lpad((floor(random()*1000000000))::text,10,'0'),
    'client' || g || '@mail.ru',
    'DL' || g
FROM generate_series(1,250000) g;

INSERT INTO car (vin, year, license_plate, color, model_id)
SELECT
    substr(md5(random()::text),1,17),
    2000 + floor(random()*24)::int,
    'A' || floor(random()*9999)::int || 'AA',
    (ARRAY['black','white','red','blue'])[floor(random()*4)+1],
    (SELECT id FROM car_model ORDER BY random() LIMIT 1)
FROM generate_series(1,250000);

INSERT INTO car_client (car_id, client_id)
SELECT
    floor(random()*250000)+1,
    floor(random()*250000)+1
FROM generate_series(1,250000);

INSERT INTO client_order
(id_client,id_car,id_location,employee_id,status,priority,total_amount)
SELECT
    floor(random()*250000)+1,
    floor(random()*250000)+1,
    (SELECT id FROM location ORDER BY random() LIMIT 1),
    (SELECT id FROM employee ORDER BY random() LIMIT 1),

    CASE
        WHEN random() < 0.7 THEN 'создан'
        WHEN random() < 0.9 THEN 'в работе'
        ELSE 'выполнен'
    END,

    (ARRAY['низкий','обычный','высокий','срочный'])[floor(random()*4)+1],

    floor(random()*10000)
FROM generate_series(1,250000);

INSERT INTO client_order_items
(id_order,product_price_id,quantity,unit_price)
SELECT
    floor(random()*250000)+1,
    (SELECT id FROM product_prices ORDER BY random() LIMIT 1),
    floor(random()*5)+1,
    floor(random()*1000)+100
FROM generate_series(1,250000);