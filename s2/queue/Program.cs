using Npgsql;

var connectionString = Environment.GetEnvironmentVariable("CAR_SERVICE_DB")
    ?? "Host=localhost;Port=5432;Database=carservice;Username=postgres;Password=postgres";
var mode = args.FirstOrDefault()?.ToLowerInvariant();

if (mode == "producer")
{
    await RunProducer(connectionString);
}
else if (mode == "worker")
{
    await RunWorker(connectionString, args.ElementAtOrDefault(1) ?? Environment.MachineName);
}
else
{
    Console.WriteLine("Usage: dotnet run -- producer | worker <name>");
}

static async Task RunProducer(string connectionString)
{
    while (true)
    {
        await using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync();
        await using var transaction = await connection.BeginTransactionAsync();

        var priority = Random.Shared.Next(100) < 20 ? 100 : 0;
        await using var insert = new NpgsqlCommand("""
            INSERT INTO queue_task(task_type, payload, priority)
            VALUES ('recalculate_order', jsonb_build_object('order_id', floor(random() * 100000)), @priority)
            RETURNING id;
            """, connection, transaction);
        insert.Parameters.AddWithValue("priority", priority);
        var taskId = (long)(await insert.ExecuteScalarAsync())!;

        await using var businessEvent = new NpgsqlCommand("""
            INSERT INTO queue_business_event(task_id, description)
            VALUES (@taskId, 'queue insert committed with business event');
            SELECT pg_notify('queue_task_created', CAST(@taskId AS text));
            """, connection, transaction);
        businessEvent.Parameters.AddWithValue("taskId", taskId);
        await businessEvent.ExecuteNonQueryAsync();
        await transaction.CommitAsync();

        await Task.Delay(5); // Около 200 событий/с от одного producer.
    }
}

static async Task RunWorker(string connectionString, string workerName)
{
    while (true)
    {
        await using var connection = new NpgsqlConnection(connectionString);
        await connection.OpenAsync();
        await using var transaction = await connection.BeginTransactionAsync();

        await using var take = new NpgsqlCommand("""
            WITH picked AS (
                SELECT id
                FROM queue_task
                WHERE status = 'ready' AND scheduled_at <= now()
                ORDER BY priority DESC, created_at
                FOR UPDATE SKIP LOCKED
                LIMIT 1
            )
            UPDATE queue_task AS task
            SET status = 'running', started_at = now(), attempts = attempts + 1
            FROM picked
            WHERE task.id = picked.id
            RETURNING task.id;
            """, connection, transaction);

        var result = await take.ExecuteScalarAsync();
        await transaction.CommitAsync();
        if (result is not long taskId)
        {
            await Task.Delay(250);
            continue;
        }

        await Task.Delay(Random.Shared.Next(50, 151));
        var failed = Random.Shared.Next(100) < 5;
        var finishSql = failed
            ? """
              UPDATE queue_task
              SET status = 'ready', scheduled_at = now() + interval '5 minutes'
              WHERE id = @taskId;
              """
            : """
              UPDATE queue_task
              SET status = 'completed', completed_at = now()
              WHERE id = @taskId;
              """;

        await using var finish = new NpgsqlCommand(finishSql, connection);
        finish.Parameters.AddWithValue("taskId", taskId);
        await finish.ExecuteNonQueryAsync();
        Console.WriteLine($"{workerName}: task={taskId}, failed={failed}");
    }
}
