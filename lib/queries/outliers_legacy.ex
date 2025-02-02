defmodule EctoPSQLExtras.OutliersLegacy do
  @behaviour EctoPSQLExtras

  def info do
    %{
      title: "10 queries that have longest execution time in aggregate",
      order_by: [exec_time: :desc],
      limit: 10,
      columns: [
        %{name: :query, type: :string},
        %{name: :exec_time, type: :interval},
        %{name: :prop_exec_time, type: :percent},
        %{name: :calls, type: :integer},
        %{name: :sync_io_time, type: :interval}
      ]
    }
  end

  def query do
    """
    /* ECTO_PSQL_EXTRAS: 10 queries that have longest execution time in aggregate */

    SELECT query AS query,
    interval '1 millisecond' * total_time AS exec_time,
    (total_time/sum(total_time) OVER()) AS prop_exec_time,
    calls,
    interval '1 millisecond' * (blk_read_time + blk_write_time) AS sync_io_time
    FROM pg_stat_statements WHERE userid = (SELECT usesysid FROM pg_user WHERE usename = current_user LIMIT 1)
    AND query NOT LIKE '/* ECTO_PSQL_EXTRAS:%'
    ORDER BY total_time DESC
    LIMIT 10;
    """
  end
end
