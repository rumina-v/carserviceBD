INSERT INTO client (full_name, phone_number, email, driver_license) VALUES
('Иванов Иван Иванович', '+79001234567', 'ivanov@example.com', 'A1234567'),
('Петров Петр Петрович', '+79007654321', 'petrov@example.com', 'B7654321'),
('Сидорова Анна Сергеевна', '+79005554433', 'sidorova@example.com', 'C1122334');

INSERT INTO location (address, phone_number, working_hours) VALUES
('Москва, ул. Ленина, 1', '+74951234567', '9:00-18:00'),
('Москва, ул. Тверская, 10', '+74959876543', '8:00-20:00');

INSERT INTO supplier (company_name, phone_number, email, bank_account) VALUES
('ООО АвтоЗапчасти', '+74951230000', 'info@autoparts.ru', '40702810900000000001'),
('ООО ДетальСнаб', '+74959870000', 'sales@detailsnab.ru', '40702810900000000002');

INSERT INTO car_model (model_name, brand_name) VALUES
('Camry', 'Toyota'),
('Rio', 'Kia'),
('Focus', 'Ford');

INSERT INTO car (vin, year, license_plate, color, model_id) VALUES
('JTNB11HK0K3000001', 2019, 'А123ВС77', 'Черный', 1),
('XWEH241ADK0000002', 2020, 'В456ОР77', 'Белый', 2),
('WF0LXXGCBL0000003', 2018, 'Е789КХ77', 'Синий', 3);

INSERT INTO car_client (car_id, client_id) VALUES
(1,1),
(2,2),
(3,3);

INSERT INTO employee (position, location_id, status, full_name, phone_number, hire_date) VALUES
('Механик',1,'работает','Смирнов Алексей Олегович','+79001112233','2022-05-10'),
('Администратор',2,'работает','Кузнецова Мария Игоревна','+79004445566','2021-03-15');

INSERT INTO shift_schedule (location_id, shift_date, start_time, end_time) VALUES
(1,'2024-01-10','09:00','18:00'),
(2,'2024-01-10','08:00','20:00');

INSERT INTO employee_shift_schedule (shift_schedule_id, employee_id) VALUES
(1,1),
(2,2);

INSERT INTO service (name, base_price, lead_time) VALUES
('Замена масла',1500,30),
('Диагностика',1000,20),
('Шиномонтаж',2000,40);

INSERT INTO service_prices (service_name, price, effective_date) VALUES
('Замена масла',1500,'2024-01-01'),
('Диагностика',1000,'2024-01-01'),
('Шиномонтаж',2000,'2024-01-01');

INSERT INTO nomenclature (article, name, id_supplier) VALUES
('OIL001','Моторное масло',1),
('FLT001','Масляный фильтр',1),
('TRD001','Тормозные колодки',2);

INSERT INTO product_prices (article, price, effective_date) VALUES
('OIL001',800,'2024-01-01'),
('FLT001',400,'2024-01-01'),
('TRD001',2500,'2024-01-01');

INSERT INTO remains_of_goods (location_id, article, quantity) VALUES
(1,'OIL001',20),
(1,'FLT001',15),
(2,'TRD001',10);

INSERT INTO order_to_supplier (id_supplier, id_location, total_cost, status, expected_delivery_date) VALUES
(1,1,5000,'формируется','2024-02-01'),
(2,2,10000,'отправлен','2024-02-03');

INSERT INTO supplier_order_items (id_order, article, quantity, unit_price) VALUES
(1,'OIL001',5,800),
(1,'FLT001',5,400),
(2,'TRD001',4,2500);

INSERT INTO loyalty_rules (min_points, discount_percent, level_name) VALUES
(0,0,'Базовый'),
(500,5,'Серебряный'),
(1000,10,'Золотой');

INSERT INTO loyalty_card (id_client, registration_date, last_visit_date, points_balance) VALUES
(1,'2023-01-01','2024-01-05',600),
(2,'2023-06-10','2024-01-02',200),
(3,'2023-08-15','2024-01-07',1200);

INSERT INTO client_order (id_client,id_car,id_location,employee_id,total_amount,status,priority,notes) VALUES
(1,1,1,1,2300,'создан','обычный','Замена масла'),
(2,2,2,2,1000,'в работе','низкий','Диагностика'),
(3,3,1,1,2000,'выполнен','высокий','Шиномонтаж');

INSERT INTO client_order_items (id_order,product_price_id,quantity,unit_price) VALUES
(1,1,1,800),
(1,2,1,400);

INSERT INTO client_order_services (id_order,service_price_id,quantity,unit_price) VALUES
(1,1,1,1500),
(2,2,1,1000),
(3,3,1,2000);

INSERT INTO client_order_status_log (order_id,status) VALUES
(1,'создан'),
(2,'в работе'),
(3,'выполнен');