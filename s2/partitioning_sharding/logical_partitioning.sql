-- Выполнить на publisher для проверки publish_via_partition_root.
CREATE PUBLICATION partitions_by_leaf
FOR TABLE partition_demo.repair_order_range
WITH (publish_via_partition_root = false);

CREATE PUBLICATION partitions_by_root
FOR TABLE partition_demo.repair_order_range
WITH (publish_via_partition_root = true);

-- При false изменения публикуются от имени конкретной секции.
-- При true subscriber получает изменения от имени корневой таблицы.
