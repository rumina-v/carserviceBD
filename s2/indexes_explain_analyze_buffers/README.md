# Сравнение планов выполнения запросов

Для каждого запроса сохранены три варианта плана до создания индекса и три варианта
после создания индекса:

```sql
EXPLAIN ...
EXPLAIN ANALYZE ...
EXPLAIN (ANALYZE, BUFFERS) ...
```

## 1. Диапазон по объему двигателя

```sql
SELECT id, license_plate
FROM car
WHERE engine_volume < 2;
```

Без индекса: [EXPLAIN](1_1.png), [ANALYZE](1_2.png), [BUFFERS](1_3.png).

С индексом: [EXPLAIN](1_4.png), [ANALYZE](1_5.png), [BUFFERS](1_6.png).

Индекс не всегда ускоряет запрос: при большом количестве подходящих строк
последовательное чтение может оказаться дешевле.

## 2. Равенство по объему двигателя

```sql
SELECT id, license_plate
FROM car
WHERE engine_volume = 2;
```

Без индекса: [EXPLAIN](2_1.png), [ANALYZE](2_2.png), [BUFFERS](2_3.png).

С индексом: [EXPLAIN](2_4.png), [ANALYZE](2_5.png), [BUFFERS](2_6.png).

При более селективном условии индекс дает заметный выигрыш.

## 3. Поиск по префиксу имени

```sql
SELECT full_name
FROM client
WHERE full_name LIKE 'Ал%';
```

Без индекса: [EXPLAIN](3_1.png), [ANALYZE](3_2.png), [BUFFERS](3_3.png).

С индексом: [EXPLAIN](3_4.png), [ANALYZE](3_5.png), [BUFFERS](3_6.png).

## 4. Диапазон дат регистрации поставщика

```sql
SELECT *
FROM supplier
WHERE registration_date < DATE '2024-01-21'
  AND registration_date > DATE '2023-12-09';
```

Без индекса: [EXPLAIN](4_1.png), [ANALYZE](4_2.png), [BUFFERS](4_3.png).

С индексом: [EXPLAIN](4_4.png), [ANALYZE](4_5.png), [BUFFERS](4_6.png).

## 5. Обновление нескольких автомобилей по VIN

```sql
UPDATE car
SET color = 'белый'
WHERE vin IN ('5D3C4CA4238E40006', '6391C383CD3DC5250', 'CD6124C6AE5D932CB');
```

Без индекса: [EXPLAIN](5_1.png), [ANALYZE](5_2.png), [BUFFERS](5_3.png).

С индексом: [EXPLAIN](5_4.png), [ANALYZE](5_5.png), [BUFFERS](5_6.png).

Для точечного обновления по высококардинальному полю разница наиболее заметна.
