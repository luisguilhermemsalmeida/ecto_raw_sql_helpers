# EctoRawSQLHelpers

Working with raw SQL in Ecto may be disapointing, since the lib offers little support to it.
EctoRawSQLHelpers aims to close that gap by providing helper functions when dealing with raw SQL, such as:
- Named parameters support (aka `"SELECT :one, :two" + %{one: 1, two: 2}` instead of `"SELECT $1, $2" + [1, 2]`)
- Response parsing (getting query results as lists of maps, number of rows affected on statements, etc )
- Stream support

# Usage 

TODO

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

