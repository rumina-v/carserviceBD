ALTER TABLE location
  ADD COLUMN IF NOT EXISTS coordinates point;

ALTER TABLE client_order
  ADD COLUMN IF NOT EXISTS work_period tsrange,
  ADD COLUMN IF NOT EXISTS tags text[],
  ADD COLUMN IF NOT EXISTS meta jsonb,
  ADD COLUMN IF NOT EXISTS external_id uuid;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'client_order_external_id_uniq'
  ) THEN
    ALTER TABLE client_order
      ADD CONSTRAINT client_order_external_id_uniq UNIQUE (external_id);
  END IF;
END$$;

ALTER TABLE client_order_items
  ADD COLUMN IF NOT EXISTS meta jsonb,
  ADD COLUMN IF NOT EXISTS comment text;

ALTER TABLE client_order_services
  ADD COLUMN IF NOT EXISTS meta jsonb;

CREATE INDEX IF NOT EXISTS idx_client_order_status ON client_order(status);
CREATE INDEX IF NOT EXISTS idx_client_order_priority ON client_order(priority);
CREATE INDEX IF NOT EXISTS idx_client_order_employee ON client_order(employee_id);
CREATE INDEX IF NOT EXISTS idx_client_order_created_date ON client_order(created_date);

CREATE INDEX IF NOT EXISTS idx_client_order_work_period_gist ON client_order USING GIST (work_period);

CREATE INDEX IF NOT EXISTS idx_client_order_completion_notnull
  ON client_order(completion_date)
  WHERE completion_date IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_client_order_notes_fts
  ON client_order USING GIN (to_tsvector('simple', coalesce(notes,'')));