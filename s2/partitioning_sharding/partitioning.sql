CREATE SCHEMA IF NOT EXISTS partition_demo;
SET search_path TO partition_demo, public;

-- RANGE: история заказов по месяцам.
CREATE TABLE repair_order_range (
    id bigint GENERATED ALWAYS AS IDENTITY,
    client_id bigint NOT NULL,
    opened_at date NOT NULL,
    status text NOT NULL,
    total_amount numeric(12, 2) NOT NULL
) PARTITION BY RANGE (opened_at);

CREATE TABLE repair_order_2026_01 PARTITION OF repair_order_range
FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
CREATE TABLE repair_order_2026_02 PARTITION OF repair_order_range
FOR VALUES FROM ('2026-02-01') TO ('2026-03-01');
CREATE TABLE repair_order_2026_default PARTITION OF repair_order_range DEFAULT;

CREATE INDEX ON repair_order_range (opened_at);

-- LIST: филиалы сгруппированы по регионам.
CREATE TABLE service_visit_list (
    id bigint GENERATED ALWAYS AS IDENTITY,
    region text NOT NULL,
    car_vin text NOT NULL,
    visited_at timestamptz NOT NULL DEFAULT now()
) PARTITION BY LIST (region);

CREATE TABLE service_visit_central PARTITION OF service_visit_list
FOR VALUES IN ('moscow', 'tula', 'ryazan');
CREATE TABLE service_visit_volga PARTITION OF service_visit_list
FOR VALUES IN ('kazan', 'samara', 'ulyanovsk');
CREATE TABLE service_visit_other PARTITION OF service_visit_list DEFAULT;

CREATE INDEX ON service_visit_list (region);

-- HASH: равномерно распределяем события по client_id.
CREATE TABLE client_event_hash (
    id bigint GENERATED ALWAYS AS IDENTITY,
    client_id bigint NOT NULL,
    event_type text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
) PARTITION BY HASH (client_id);

CREATE TABLE client_event_hash_0 PARTITION OF client_event_hash
FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE client_event_hash_1 PARTITION OF client_event_hash
FOR VALUES WITH (MODULUS 4, REMAINDER 1);
CREATE TABLE client_event_hash_2 PARTITION OF client_event_hash
FOR VALUES WITH (MODULUS 4, REMAINDER 2);
CREATE TABLE client_event_hash_3 PARTITION OF client_event_hash
FOR VALUES WITH (MODULUS 4, REMAINDER 3);

CREATE INDEX ON client_event_hash (client_id);

INSERT INTO repair_order_range (client_id, opened_at, status, total_amount)
SELECT n, DATE '2026-01-01' + (n % 70)::int, 'created', 1000 + n
FROM generate_series(1, 1000) AS n;

INSERT INTO service_visit_list (region, car_vin)
SELECT (ARRAY['moscow', 'kazan', 'samara', 'tula', 'perm'])[1 + (n % 5)::int],
       md5(n::text)
FROM generate_series(1, 1000) AS n;

INSERT INTO client_event_hash (client_id, event_type)
SELECT n % 200, 'order_updated'
FROM generate_series(1, 1000) AS n;

-- Для каждого EXPLAIN проверить Partition Pruning и число партиций в плане.
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM repair_order_range
WHERE opened_at >= DATE '2026-02-01' AND opened_at < DATE '2026-03-01';

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM service_visit_list
WHERE region = 'kazan';

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM client_event_hash
WHERE client_id = 42;
