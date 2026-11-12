defmodule Gsmlg.PageState.CounterReducer do
  use Phoenix.SessionProcess, :reducer
  alias Phoenix.SessionProcess.Action

  @name :counter
  @action_prefix "counter"

  @impl true
  def init_state, do: %{count: 0}

  @impl true
  def handle_action(%Action{type: "increment"}, state), do: %{state | count: state.count + 1}
  def handle_action(%Action{type: "reset"}, state), do: %{state | count: 0}
  def handle_action(_action, state), do: state
end
