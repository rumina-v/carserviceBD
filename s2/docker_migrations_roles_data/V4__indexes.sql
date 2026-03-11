CREATE INDEX IF NOT EXISTS idx_client_order_status
ON client_order(status);

CREATE INDEX IF NOT EXISTS idx_client_order_priority
ON client_order(priority);

CREATE INDEX IF NOT EXISTS idx_client_order_employee_id
ON client_order(employee_id);

CREATE INDEX IF NOT EXISTS idx_client_order_created_date
ON client_order(created_date);

CREATE INDEX IF NOT EXISTS idx_client_order_items_id_order
ON client_order_items(id_order);

CREATE INDEX IF NOT EXISTS idx_client_order_items_product_price_id
ON client_order_items(product_price_id);

CREATE INDEX IF NOT EXISTS idx_client_order_services_id_order
ON client_order_services(id_order);

CREATE INDEX IF NOT EXISTS idx_client_order_services_service_price_id
ON client_order_services(service_price_id);

CREATE INDEX IF NOT EXISTS idx_client_order_status_log_order_id
ON client_order_status_log(order_id);

CREATE INDEX IF NOT EXISTS idx_product_prices_article
ON product_prices(article);

CREATE INDEX IF NOT EXISTS idx_service_prices_service_name
ON service_prices(service_name);

CREATE INDEX IF NOT EXISTS idx_nomenclature_supplier
ON nomenclature(id_supplier);

CREATE INDEX IF NOT EXISTS idx_employee_location
ON employee(location_id);

CREATE INDEX IF NOT EXISTS idx_car_model
ON car(model_id);