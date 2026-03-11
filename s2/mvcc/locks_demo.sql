-- Row lock demo

BEGIN;
SELECT * FROM client WHERE id = 1 FOR UPDATE;

-- in another session
UPDATE client SET email = 'blocked@test.com' WHERE id = 1;