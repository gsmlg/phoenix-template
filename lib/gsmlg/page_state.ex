defmodule Gsmlg.PageState do
  @moduledoc "Node-local, expiring page state shared by tabs with the same signed browser session."
  use Phoenix.SessionProcess, :process
  alias Phoenix.SessionProcess

  @impl true
  def init_state(_args), do: %{}

  @impl true
  def combined_reducers, do: [Gsmlg.PageState.CounterReducer]

  def ensure_session(session_id) do
    # Existing sessions must not consume the new-session rate limit.
    case SessionProcess.find_session(session_id) do
      {:ok, pid} -> {:ok, pid}
      {:error, :not_found} -> start_session(session_id)
    end
  end

  defp start_session(session_id) do
    case SessionProcess.start_session(session_id, module: __MODULE__) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:error, _reason} = error -> error
    end
  end

  def read_counter(session_id) do
    case SessionProcess.get_state(session_id) do
      %{counter: %{count: count}} -> {:ok, count}
      {:error, _reason} = error -> error
    end
  end

  def update_counter(session_id, action) when action in ["increment", "reset"] do
    # dispatch is a cast in 1.0.1. Refresh activity explicitly, then read from
    # this same caller to wait until the queued action has been applied.
    with :ok <- SessionProcess.touch(session_id),
         :ok <- SessionProcess.dispatch(session_id, "counter." <> action) do
      read_counter(session_id)
    end
  end
end
