-- На router установить расширение и зарегистрировать два PostgreSQL-шарда.
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

CREATE SERVER shard_1 FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'shard1', port '5432', dbname 'carservice');

CREATE SERVER shard_2 FOREIGN DATA WRAPPER postgres_fdw
OPTIONS (host 'shard2', port '5432', dbname 'carservice');

CREATE USER MAPPING FOR CURRENT_USER SERVER shard_1
OPTIONS (user 'postgres', password 'postgres');

CREATE USER MAPPING FOR CURRENT_USER SERVER shard_2
OPTIONS (user 'postgres', password 'postgres');

CREATE SCHEMA IF NOT EXISTS shard_1;
CREATE SCHEMA IF NOT EXISTS shard_2;

IMPORT FOREIGN SCHEMA public LIMIT TO (repair_order)
FROM SERVER shard_1 INTO shard_1;

IMPORT FOREIGN SCHEMA public LIMIT TO (repair_order)
FROM SERVER shard_2 INTO shard_2;

CREATE OR REPLACE VIEW all_repair_orders AS
SELECT 'shard_1' AS source_shard, * FROM shard_1.repair_order
UNION ALL
SELECT 'shard_2' AS source_shard, * FROM shard_2.repair_order;

EXPLAIN (VERBOSE) SELECT * FROM all_repair_orders;
EXPLAIN (VERBOSE) SELECT * FROM shard_1.repair_order;
