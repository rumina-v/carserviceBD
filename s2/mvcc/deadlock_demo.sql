BEGIN;
UPDATE client SET email = 'deadlock1@test.com' WHERE id = 1;

BEGIN;
UPDATE client SET email = 'deadlock2@test.com' WHERE id = 2;

UPDATE client SET email = 'deadlock1@test.com' WHERE id = 2;

UPDATE client SET email = 'deadlock2@test.com' WHERE id = 1;