# EctoRawSQLHelpers

Working with raw SQL in Ecto may be disapointing, since the lib offers little support to it.
EctoRawSQLHelpers aims to close that gap by providing helper functions when dealing with raw SQL, such as:
- Named parameters support (aka `"SELECT :one, :two" + %{one: 1, two: 2}` instead of `"SELECT $1, $2" + [1, 2]`)
- Response parsing (getting query results as lists of maps, number of rows affected on statements, etc )
- Stream support

# Usage 

## Runnings Queries (eager)

`query(Repo, SQL, parameters, options)` is the go-to function for queries, it will return a list of maps, where the keys will be the database columns.
```elixir
alias EctoRawSQLHelpers.SQL

SQL.query(MyApplication.Repo, "SELECT * FROM table")
#> [%{id: 1, column_name: "some value"}, %{id: 2, column_name: "some value"}]
```


For single result queries, the function `query_get_single_result/4` might be useful. This function will return either:
- a map, when the query returned exactly one row
- nil, when the query result set was empty
- {:error, "string"}, when the result set had more than one row (use the LIMIT clause if you need)

```elixir
alias EctoRawSQLHelpers.SQL

SQL.query_get_single_result(MyApplication.Repo, "SELECT * FROM table WHERE id = :id", %{id: 2})
#> %{id: 2, column_name: "some value"}
#> nil
#> {:error, "query_get_single_result_as_map returned more than one row, 2 rows returned"}

```

## Running Queries (Lazy evaluation / Stream)
When you wish to run queries that can return large result sets, it might be wise to use `Streams` when dealing with such data.
This lib offers two ways of Streaming result sets from the database
- `SQLStream.query/4`
- `SQLStream.cursor_stream/4`

`SQLStream.query/4` will query the whole dataset from the database and then stream each row individually. Because the query is fetched from the databse all at once, it can still be quite memory intensive.

`SQLStream.cursor/4` will leverage Ecto cursors to Stream data directly from the database. By doing so, only chunks of data will be queried at a time and the memory usage might be dramatically lower.
Keep in mind though, that internally, this function will use a database transaction, which may lead to performance issues in your database server.

```elixir
alias EctoRawSQLHelpers.SQLStream

SQLStream.query(MyApplication.Repo, "SELECT * FROM table")
|> Stream.map(&transformation/1)
|> Enum.reduce(&sum/2)

SQLStream.cursor(MyApplication.Repo, "SELECT * FROM table")
|> Stream.map(&transformation/1)
|> Enum.reduce(&sum/2)
```
Both methods will yield the same results. 
- using `SQLStream.query/4` will generally be faster, since there is no overhead of using database cursors.
- using `SQLStream.cursor/4` will generally be slower, but will use much less memory 

### Options

The last argument of the functions in this lib is the `options` parameter. It is a `Keyword List` that have the following tweaks: 
- `:column_names_as_atoms` This option controls whether the column names returned will be strings or atoms. Defaults to false. Can be controlled using a ENV with the same name.
- `:adapter_sql_function` This option controls the function used to run the query in the database, it defaults to `&Ecto.Adapters.SQL.query/4`. If you wish to do some pre-processing just before querying the database, you can use this option to do so. You may also use it to return mocked responses.

### Config
You may also use the following configs in your config.exs file:
```elixir
config :ecto_raw_sql_helper, [
  column_names_as_atoms: true
]
```

## Parameter Binding
This lib providers named parameter binding. When running a query, you may specify parameters using the following syntax `:parameter_name` and then send the parameter as a map `%{parameter_name: "value"}`.

### Array binding
Postgres supports array binding for some queries, example:

```elixir
SQL.query(MyApplication.Repo, "SELECT * FROM table WHERE id = ANY(:ids)", %{ids: [1, 2, 3]})
```
However, if you are using MySQL or prefer to use the `IN` sql clause, we got your back :)

```elixir
SQL.query(MyApplication.Repo, "SELECT * FROM table WHERE id IN (:ids)", %{ids: {:in, [1, 2, 3]}})
```

Both will yield the same results as expected.

# Contributors
Special thanks to these un-oficial contributors for code reviews and pair-programming:

![https://github.com/jomaro](https://github.com/jomaro.png?size=50)
![https://github.com/thiagopromano](https://github.com/thiagopromano.png?size=50)
# Installation

Add `ecto_raw_sql_helpers` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
     {:ecto_raw_sql_helpers, git: "https://github.com/leveexpress/ecto_raw_sql_helpers.git", branch: "main"},
  ]
end
```

