SET ROLE analyst_ro;
SELECT count(*) FROM client_order;
RESET ROLE;

SET ROLE etl_loader;
INSERT INTO client_order_status_log(order_id, status) VALUES (1, 'создан');
SELECT * FROM client_order_status_log WHERE order_id = 1;
RESET ROLE;

SET ROLE app_rw;
UPDATE client
SET email = 'test_access@app.ru'
WHERE id = 1;
DELETE FROM client_order_status_log
WHERE order_id = 1 AND status = 'создан';
RESET ROLE;