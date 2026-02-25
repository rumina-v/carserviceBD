CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'employee_status') THEN
    CREATE TYPE employee_status AS ENUM ('работает', 'уволен', 'отпуск');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'order_priority') THEN
    CREATE TYPE order_priority AS ENUM ('низкий', 'обычный', 'высокий', 'срочный');
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'order_status') THEN
    CREATE TYPE order_status AS ENUM ('создан', 'в работе', 'выполнен', 'отменен');
  END IF;
END$$;

CREATE TABLE IF NOT EXISTS location (
  id serial PRIMARY KEY,
  address varchar(200) NOT NULL,
  phone_number varchar(12) NOT NULL CHECK (phone_number ~ '^\+7[0-9]{10}$'),
  working_hours varchar(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS supplier (
  id serial PRIMARY KEY,
  company_name varchar(200) NOT NULL,
  phone_number varchar(12) NOT NULL CHECK (phone_number ~ '^\+7[0-9]{10}$'),
  email varchar(100),
  bank_account varchar(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS car_model (
  id serial PRIMARY KEY,
  model_name varchar(50) NOT NULL,
  brand_name varchar(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS car (
  id serial PRIMARY KEY,
  vin varchar(17) NOT NULL UNIQUE,
  year integer NOT NULL CHECK (year >= 1990 AND year <= EXTRACT(year FROM CURRENT_DATE)),
  license_plate varchar(15),
  color varchar(30),
  model_id integer NOT NULL REFERENCES car_model(id)
);

CREATE TABLE IF NOT EXISTS client (
  id serial PRIMARY KEY,
  full_name varchar(100) NOT NULL,
  phone_number varchar(12) NOT NULL CHECK (phone_number ~ '^\+7[0-9]{10}$'),
  email varchar(100),
  driver_license varchar(20) UNIQUE
);

CREATE TABLE IF NOT EXISTS employee (
  id serial PRIMARY KEY,
  position varchar(50) NOT NULL,
  location_id integer NOT NULL REFERENCES location(id),
  status employee_status NOT NULL,
  full_name varchar(100) NOT NULL,
  phone_number varchar(12) NOT NULL CHECK (phone_number ~ '^\+7[0-9]{10}$'),
  hire_date date NOT NULL
);

CREATE TABLE IF NOT EXISTS service (
  name varchar(100) PRIMARY KEY,
  base_price integer NOT NULL CHECK (base_price > 0),
  lead_time integer NOT NULL CHECK (lead_time > 0)
);

CREATE TABLE IF NOT EXISTS service_prices (
  id serial PRIMARY KEY,
  service_name varchar(100) NOT NULL REFERENCES service(name),
  price integer NOT NULL CHECK (price > 0),
  effective_date date DEFAULT CURRENT_DATE NOT NULL,
  UNIQUE (service_name, effective_date)
);

CREATE TABLE IF NOT EXISTS nomenclature (
  article varchar(30) PRIMARY KEY,
  name varchar(200) NOT NULL,
  id_supplier integer NOT NULL REFERENCES supplier(id)
);

CREATE TABLE IF NOT EXISTS product_prices (
  id serial PRIMARY KEY,
  article varchar(30) NOT NULL REFERENCES nomenclature(article),
  price integer NOT NULL CHECK (price > 0),
  effective_date date DEFAULT CURRENT_DATE NOT NULL,
  UNIQUE (article, effective_date)
);

CREATE TABLE IF NOT EXISTS client_order (
  id serial PRIMARY KEY,
  id_client integer NOT NULL REFERENCES client(id),
  id_car integer NOT NULL REFERENCES car(id),
  id_location integer NOT NULL REFERENCES location(id),
  employee_id integer NOT NULL REFERENCES employee(id),
  created_date timestamp DEFAULT CURRENT_TIMESTAMP NOT NULL,
  total_amount integer NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
  status order_status DEFAULT 'создан' NOT NULL,
  completion_date timestamp,
  notes text,
  priority order_priority DEFAULT 'обычный' NOT NULL,
  CHECK (completion_date IS NULL OR completion_date >= created_date)
);

CREATE TABLE IF NOT EXISTS client_order_items (
  id serial PRIMARY KEY,
  id_order integer NOT NULL REFERENCES client_order(id),
  product_price_id integer NOT NULL REFERENCES product_prices(id),
  quantity integer NOT NULL CHECK (quantity > 0),
  unit_price integer NOT NULL CHECK (unit_price > 0),
  total_price integer GENERATED ALWAYS AS (quantity * unit_price) STORED
);

CREATE TABLE IF NOT EXISTS client_order_services (
  id serial PRIMARY KEY,
  id_order integer NOT NULL REFERENCES client_order(id),
  service_price_id integer NOT NULL REFERENCES service_prices(id),
  quantity integer NOT NULL DEFAULT 1 CHECK (quantity > 0),
  unit_price integer NOT NULL CHECK (unit_price > 0),
  total_price integer GENERATED ALWAYS AS (quantity * unit_price) STORED
);

CREATE TABLE IF NOT EXISTS client_order_status_log (
  id serial PRIMARY KEY,
  order_id integer NOT NULL REFERENCES client_order(id),
  status order_status NOT NULL,
  changed_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);