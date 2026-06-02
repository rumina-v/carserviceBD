CREATE SCHEMA IF NOT EXISTS olap;

CREATE TABLE IF NOT EXISTS olap.dim_date (
    date_key integer PRIMARY KEY,
    full_date date NOT NULL UNIQUE,
    year integer NOT NULL,
    month integer NOT NULL,
    day integer NOT NULL,
    day_of_week integer NOT NULL
);

CREATE TABLE IF NOT EXISTS olap.dim_client (
    client_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    client_id bigint NOT NULL UNIQUE,
    full_name text NOT NULL,
    loaded_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS olap.dim_service (
    service_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    service_id bigint NOT NULL UNIQUE,
    service_name text NOT NULL,
    loaded_at timestamptz NOT NULL DEFAULT now()
);

-- Зерно факта: одна оказанная услуга в заказе автосервиса.
CREATE TABLE IF NOT EXISTS olap.fact_service_order (
    service_order_key bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id bigint NOT NULL,
    date_key integer NOT NULL REFERENCES olap.dim_date(date_key),
    client_key bigint NOT NULL REFERENCES olap.dim_client(client_key),
    service_key bigint NOT NULL REFERENCES olap.dim_service(service_key),
    amount numeric(12, 2) NOT NULL,
    quantity integer NOT NULL DEFAULT 1,
    loaded_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (order_id, service_key)
);

INSERT INTO olap.dim_date (date_key, full_date, year, month, day, day_of_week)
SELECT to_char(d, 'YYYYMMDD')::integer,
       d,
       extract(year FROM d)::integer,
       extract(month FROM d)::integer,
       extract(day FROM d)::integer,
       extract(isodow FROM d)::integer
FROM generate_series(DATE '2025-01-01', DATE '2026-12-31', interval '1 day') AS d
ON CONFLICT (date_key) DO NOTHING;

-- Пример идемпотентной загрузки из OLTP. Имена полей при необходимости
-- адаптируются под фактическую схему проекта.
--
-- INSERT INTO olap.dim_client (client_id, full_name)
-- SELECT id, full_name FROM public.client
-- ON CONFLICT (client_id) DO UPDATE SET full_name = EXCLUDED.full_name;
--
-- INSERT INTO olap.dim_service (service_id, service_name)
-- SELECT id, name FROM public.service
-- ON CONFLICT (service_id) DO UPDATE SET service_name = EXCLUDED.service_name;
