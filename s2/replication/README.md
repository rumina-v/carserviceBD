# Репликация PostgreSQL

## Архитектура

```text
                    WAL stream
carservice-primary --------+--------> carservice-replica1
        :5432              |
                           +--------> carservice-replica2
                                      :5433 / :5434 на хосте
```

## Физическая потоковая репликация

Запуск:

```bash
docker compose up -d
```

Проверка записи на primary:

```bash
docker exec carservice-primary psql -U postgres -d carservice -c \
  "INSERT INTO service_event(event_type, payload) VALUES ('repair_created', '{\"order_id\":101}');"
```

Проверка строки на репликах:

```bash
docker exec carservice-replica1 psql -U postgres -d carservice -c "TABLE service_event;"
docker exec carservice-replica2 psql -U postgres -d carservice -c "TABLE service_event;"
```

Попытка `INSERT` на реплике завершается ошибкой: physical standby работает в
режиме read-only. Состояние и lag проверяются запросами из [status.sql](status.sql).
Для наблюдения lag можно выполнить серию `INSERT` на primary и повторять запрос
к `pg_stat_replication`.

## Логическая репликация

Порядок экспериментов записан в [logical_replication.sql](logical_replication.sql).
Проверяются `PUBLICATION`, `SUBSCRIPTION`, отсутствие автоматической репликации
DDL и необходимость `REPLICA IDENTITY` для `UPDATE`/`DELETE` таблицы без PK.

`pg_dump --schema-only` полезен перед созданием subscription: схема таблиц на
subscriber должна быть подготовлена отдельно.
