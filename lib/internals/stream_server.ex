defmodule EctoRawSQLHelpers.StreamServer do
  defmodule StreamRequest do
    defstruct [
      :client_pid,
      :instruction,
    ]
  end
  defmodule StreamResponse do
    defstruct [
      :server_pid,
      :state,
      :data,
    ]
  end

  def initialize_stream_server_and_wait_for_demand(repo_or_pid, sql, params, options) do
    spawn_link(
      fn ->
        repo_or_pid.transaction(
          fn ->
            Ecto.Adapters.SQL.stream(repo_or_pid, sql, params, options)
            |> Enum.each(&wait_for_demand_and_send_response/1)

            wait_for_demand_and_send_finished_state()
          end
        )
      end
    )
  end

  defp wait_for_demand_and_send_response(chunk) do
    receive do
      %StreamRequest{
        client_pid: pid,
        instruction: :next_page
      } -> send(pid, %StreamResponse{server_pid: self(), state: :ok, data: chunk})
    end
  end

  defp wait_for_demand_and_send_finished_state() do
    receive do
      %StreamRequest{
        client_pid: pid,
        instruction: :next_page
      } -> send(pid, %StreamResponse{server_pid: self(), state: :finished})
    end
  end
end
