# EctoRawSQLHelpers

Working with raw SQL in Ecto may be disapointing, since the lib offers little support to it.
EctoRawSQLHelpers aims to close that gap by providing helper functions when dealing with raw SQL, such as:
- Named parameters support (aka `"SELECT :one, :two"` binding `%{one: 1, two: 2}` instead of `"SELECT $1, $2"` binding `[1, 2]`)
- Response parsing (getting query results as lists of maps, number of rows affected on statements, etc )
- Stream support for dealing with big result sets

# Usage 

## Runnings Queries (eager)

`query(Repo, SQL, parameters, options)` is the go-to function for queries, it will return a list of maps, where the keys will be the database columns.
```elixir
alias EctoRawSQLHelpers.SQL

SQL.query(MyApplication.Repo, "SELECT * FROM table")
#> [%{"id" => 1, "column_name" => "some value"}, %{"id" => 2, "column_name" => "some value"}]
```


For single result queries, the function `query_get_single_result/4` might be useful. This function will return either:
- a map, when the query returned exactly one row
- nil, when the query result set was empty
- {:error, "string"}, when the result set had more than one row (use the LIMIT clause if you need)

```elixir
alias EctoRawSQLHelpers.SQL

SQL.query_get_single_result(MyApplication.Repo, "SELECT * FROM table WHERE id = :id", %{id: 2}, column_names_as_atoms: true)
#> %{id: 2, column_name: "some value"}
#> nil
#> {:error, "query_get_single_result_as_map returned more than one row, 2 rows returned"}

```

## Running Queries (Lazy evaluation / Stream)
When you wish to run queries that can return large result sets, it might be wise to use `Streams` when dealing with such data.
This lib offers two ways of Streaming result sets from the database
- `SQLStream.query/4`
- `SQLStream.cursor/4`

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
Both methods will yield the same results. Considering the table has many rows (> 100k)
- using `SQLStream.query/4` will generally be faster, since there is no overhead of using database cursors.
- using `SQLStream.cursor/4` will generally be slower, but will use dramatically less memory 

### Options

The last argument of the functions in this lib is the `options` parameter. It is a `Keyword List` that have the following tweaks: 
- `:column_names_as_atoms` This option controls whether the column names returned will be strings or atoms. Defaults to false. Can be controlled using a ENV with the same name.
- `:adapter_sql_function` This option controls the function used to run the query in the database, it defaults to `&Ecto.Adapters.SQL.query/4`. If you wish to do some pre-processing just before querying the database, you can use this option to do so. You may also use it to return mocked responses.

## Affecting statements (INSERTs, UPDATEs, DELETEs, etc)
When running affecting statments such as a UPDATE or DELETE, it's sometimes useful to know the number of rows affected in the database.

This lib also offers functions for that matter:
- `SQL.affecting_statement/4`
- `SQL.affecting_statement_and_return_rows/4` (postgres only)
- `SQL.affecting_statement_and_return_single_row/4` (postgres only)

```elixir
alias EctoRawSQLHelpers.SQL

SQLStream.affecting_statement(
  MyApplication.Repo,
  "INSERT INTO table (id) VALUES (:first_value), (:second_value)",
  %{"first_value" => 1, "second_value" => 2}
)
#> 2

# the RETURNING clause is not available in MySQL,
# instead you would use the LAST_INSERT_ID() function
SQLStream.affecting_statement_and_return_rows(
  MyApplication.Repo,
  "INSERT INTO table (value) VALUES (:first_value), (:second_value) RETURNING id",
  %{first_value: "value", second_value: "value2"}
)
#> [%{"id" => 1}, %{"id" => 2}]
```

## Parameter Binding
This lib providers named parameter binding. When running a query, you may specify parameters using the following syntax `WHERE value = :parameter_name` and then send the parameter as a map `%{"parameter_name" => "value"}`.
The parameters can be both atoms or strings, so `%{parameter_name: "value"}` is also accepted. (if the same key is sent twice, the string version will be used)

### Array binding
Postgres supports array binding for some queries, example:

```elixir
SQL.query(MyApplication.Repo, "SELECT * FROM table WHERE id = ANY(:ids)", %{ids: [1, 2, 3]})
```
However, if you are using MySQL or prefer to use the `IN` sql clause, we got your back 🙂

```elixir
SQL.query(MyApplication.Repo, "SELECT * FROM table WHERE id IN (:ids)", %{ids: {:in, [1, 2, 3]}})
```

Both will yield the same results as expected.

## Config
You may also use the following configs in your config.exs file:
```elixir
config :ecto_raw_sql_helpers, [
  column_names_as_atoms: true
]
```

### Postgres UUID
An UUID value returned by a postgres column will be a binary value that cannot be differenciated from a regular string. This lib also provides a custom UUID handler that can be activated by including the following option in your Repo config:
```elixir
  config :myapp, MyApp.Repo,
       #...
       types: EctoRawSQLHelpers.Postgrex.CustomUUIDType
```
By using the `CustomUUIDType`, UUID fields will cast UUIDs to strings automatically:

```elixir
SQL.query_get_single_result(MyApplication.Repo, "SELECT id FROM table_uuid WHERE id = :id", %{id: "7c5aa420-3245-4188-a9c3-2c16357afddd"})
#> %{id: "7c5aa420-3245-4188-a9c3-2c16357afddd"}
```


# Contributors
Special thanks to these contributors for code reviews and pair-programming:

![https://github.com/jomaro](https://github.com/jomaro.png?size=50)
![https://github.com/thiagopromano](https://github.com/thiagopromano.png?size=50)

- [@jomaro](https://github.com/jomaro)
- [@thiagopromano](https://github.com/thiagopromano)
# Installation

Add `ecto_raw_sql_helpers` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
     {:ecto_raw_sql_helpers, "~> 0.1.2"},
  ]
end
```

