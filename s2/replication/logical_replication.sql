-- Выполнить на publisher.
CREATE TABLE IF NOT EXISTS logical_demo (
    id bigint PRIMARY KEY,
    description text NOT NULL,
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE PUBLICATION carservice_publication FOR TABLE logical_demo;

-- Выполнить на subscriber после создания такой же таблицы logical_demo.
-- Подставить доступный адрес publisher:
-- CREATE SUBSCRIPTION carservice_subscription
-- CONNECTION 'host=primary port=5432 dbname=carservice user=postgres password=postgres'
-- PUBLICATION carservice_publication;

-- Проверка DML на publisher:
INSERT INTO logical_demo (id, description) VALUES (1, 'проверка logical replication');
UPDATE logical_demo SET description = 'обновление реплицируется' WHERE id = 1;

-- DDL не переносится логической репликацией:
ALTER TABLE logical_demo ADD COLUMN IF NOT EXISTS note text;

-- Проверка REPLICA IDENTITY для таблицы без PK:
CREATE TABLE IF NOT EXISTS logical_without_pk (description text);
ALTER PUBLICATION carservice_publication ADD TABLE logical_without_pk;
-- UPDATE/DELETE потребуют REPLICA IDENTITY FULL:
ALTER TABLE logical_without_pk REPLICA IDENTITY FULL;
