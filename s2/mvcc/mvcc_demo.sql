INSERT INTO client (full_name, phone_number, email, driver_license)
VALUES ('MVCC Test', '+79990000000', 'mvcc@test.com', 'MVCC001');

SELECT xmin, xmax, ctid, *
FROM client
WHERE full_name = 'MVCC Test';

UPDATE client
SET email = 'mvcc_updated@test.com'
WHERE full_name = 'MVCC Test';

SELECT xmin, xmax, ctid, *
FROM client
WHERE full_name = 'MVCC Test';