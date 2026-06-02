CREATE TABLE IF NOT EXISTS queue_task (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_type text NOT NULL,
    payload jsonb NOT NULL,
    priority integer NOT NULL CHECK (priority IN (0, 100)),
    status text NOT NULL DEFAULT 'ready'
        CHECK (status IN ('ready', 'running', 'completed', 'failed')),
    attempts integer NOT NULL DEFAULT 0,
    scheduled_at timestamptz NOT NULL DEFAULT now(),
    created_at timestamptz NOT NULL DEFAULT now(),
    started_at timestamptz,
    completed_at timestamptz
);

CREATE TABLE IF NOT EXISTS queue_business_event (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    task_id bigint NOT NULL REFERENCES queue_task(id),
    description text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_queue_task_pick
ON queue_task (priority DESC, scheduled_at, created_at)
WHERE status = 'ready';

ALTER TABLE queue_task SET (
    autovacuum_vacuum_scale_factor = 0.02,
    autovacuum_analyze_scale_factor = 0.01
);

-- Лаг самой старой готовой задачи.
SELECT now() - min(created_at) AS oldest_ready_lag
FROM queue_task
WHERE status = 'ready';

-- Пропускная способность за последнюю минуту.
SELECT count(*) / 60.0 AS tasks_per_second
FROM queue_task
WHERE status = 'completed'
  AND completed_at >= now() - interval '1 minute';
