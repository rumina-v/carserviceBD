CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'replicatorpass';

CREATE TABLE service_event (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_type text NOT NULL,
    payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now()
);

INSERT INTO service_event (event_type, payload)
VALUES ('database_started', '{"source":"primary"}');
