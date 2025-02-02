defmodule EctoPSQLExtras.Blocking do
  @behaviour EctoPSQLExtras

  def info do
    %{
      title: "Queries holding locks other queries are waiting to be released",
      columns: [
        %{name: :blocked_pid, type: :integer},
        %{name: :blocking_statement, type: :string},
        %{name: :blocking_duration, type: :interval},
        %{name: :blocking_pid, type: :integer},
        %{name: :blocked_statement, type: :string},
        %{name: :blocked_duration, type: :interval}
      ]
    }
  end

  def query do
    """
    /* ECTO_PSQL_EXTRAS: Queries holding locks other queries are waiting to be released */

    SELECT bl.pid AS blocked_pid,
      ka.query AS blocking_statement,
      now() - ka.query_start AS blocking_duration,
      kl.pid AS blocking_pid,
      a.query AS blocked_statement,
      now() - a.query_start AS blocked_duration
    FROM pg_catalog.pg_locks bl
    JOIN pg_catalog.pg_stat_activity a
      ON bl.pid = a.pid
    JOIN pg_catalog.pg_locks kl
      JOIN pg_catalog.pg_stat_activity ka
        ON kl.pid = ka.pid
    ON bl.transactionid = kl.transactionid AND bl.pid != kl.pid
    WHERE NOT bl.granted;
    """
  end
end
