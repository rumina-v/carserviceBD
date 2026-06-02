-- 1. Динамика выручки и количества оказанных услуг по дням.
SELECT d.full_date,
       count(*) AS services_count,
       sum(f.amount * f.quantity) AS revenue
FROM olap.fact_service_order AS f
JOIN olap.dim_date AS d USING (date_key)
GROUP BY d.full_date
ORDER BY d.full_date;

-- 2. Самые популярные услуги.
SELECT s.service_name,
       sum(f.quantity) AS sold_count,
       sum(f.amount * f.quantity) AS revenue
FROM olap.fact_service_order AS f
JOIN olap.dim_service AS s USING (service_key)
GROUP BY s.service_name
ORDER BY sold_count DESC
LIMIT 10;

-- 3. Клиенты с наибольшей суммарной выручкой.
SELECT c.full_name,
       count(DISTINCT f.order_id) AS orders_count,
       sum(f.amount * f.quantity) AS revenue
FROM olap.fact_service_order AS f
JOIN olap.dim_client AS c USING (client_key)
GROUP BY c.full_name
ORDER BY revenue DESC
LIMIT 10;
