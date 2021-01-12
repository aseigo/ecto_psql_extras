defmodule EctoPSQLExtras.LongRunningQueries do
  @behaviour EctoPSQLExtras

  def info do
    %{
      title: "All queries longer than five minutes by descending duration",
      order_by: [duration: :desc],
      columns: [
        %{name: :pid, type: :int},
        %{name: :duration, type: :interval},
        %{name: :query, type: :string}
      ]
    }
  end

  def query do
    """
    /* ECTO_PSQL_EXTRAS: All queries longer than five minutes by descending duration */

    SELECT
      pid,
      now() - pg_stat_activity.query_start AS duration,
      query AS query
    FROM
      pg_stat_activity
    WHERE
      pg_stat_activity.query <> ''::text
      AND state <> 'idle'
      AND now() - pg_stat_activity.query_start > interval '5 minutes'
    ORDER BY
      now() - pg_stat_activity.query_start DESC;
    """
  end
end
