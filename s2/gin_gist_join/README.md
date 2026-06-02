# GIN, GiST и JOIN

## GIN

Проверены JSONB, полнотекстовый поиск и массивы:

```sql
CREATE INDEX idx_features_gin ON car USING GIN (features);
CREATE INDEX idx_description_gin ON supplier USING GIN (to_tsvector('russian', description));
CREATE INDEX idx_tags_gin ON supplier USING GIN (tags);
```

Сравнения до и после создания индекса:

| Запрос | Без индекса | С индексом |
| --- | --- | --- |
| `features @> '{"climate": "dual"}'` | [план](1_1_1.png) | [план](1_1_2.png) |
| полнотекстовый поиск поставщика | [план](1_2_1.png) | [план](1_2_2.png) |
| поиск двух тегов | [план](1_3_1.png) | [план](1_3_2.png) |
| поиск трех тегов | [план](1_4_1.png) | [план](1_4_2.png) |
| `UPDATE` по тегам | [план](1_5_1.png) | [план](1_5_2.png) |

## GiST

Проверены полнотекстовый поиск и геометрические поля:

```sql
CREATE INDEX idx_description_gist ON supplier USING GIST (to_tsvector('russian', description));
CREATE INDEX idx_client_location_gist ON client USING GIST (location);
CREATE INDEX idx_supplier_location_gist ON supplier USING GIST (location);
```

| Запрос | Без индекса | С индексом |
| --- | --- | --- |
| полнотекстовый поиск | [план](2_1_1.png) | [план](2_1_2.png) |
| поиск клиентов внутри окружности | [план](2_2_1.png) | [план](2_2_2.png) |
| `UPDATE` JSONB поставщика | [план](2_3_1.png) | [план](2_3_2.png) |
| смещение координат поставщика | [план](2_4_1.png) | [план](2_4_2.png) |
| `DELETE` по рейтингу | [план](2_5_1.png) | [план](2_5_2.png) |

## JOIN

Дополнительно проверены разные условия объединения:

| Вариант | План |
| --- | --- |
| `client.id = client_order.id_client` | [план](3_1.png) |
| `client.client_status = client_order.employee_id` | [план](3_2.png) |
| `client.age = client_order.employee_id * 10` | [до](3_3.png), [после](3_3_2.png) |
| `client.age * 1000 = car.mileage` | [до](3_4.png), [после](3_4_2.png) |

Вывод: тип индекса выбирается по оператору и типу данных. GIN удобен для
JSONB, массивов и полнотекстового поиска; GiST подходит для геометрии и
поисковых деревьев; индекс для JOIN полезен только при подходящей
селективности и условии объединения.
