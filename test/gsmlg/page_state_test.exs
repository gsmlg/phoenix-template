defmodule Gsmlg.PageStateTest do
  use ExUnit.Case, async: false
  alias Gsmlg.PageState
  alias Phoenix.SessionProcess

  setup do
    id = SessionProcess.SessionId.generate_unique_session_id()
    on_exit(fn -> SessionProcess.terminate(id) end)
    %{session_id: id}
  end

  test "same session reuses a process and reductions publish ordered state", %{session_id: id} do
    assert {:ok, pid} = PageState.ensure_session(id)
    assert {:ok, ^pid} = PageState.ensure_session(id)
    assert {:ok, _ref} = SessionProcess.subscribe(id, & &1.counter, :counter)
    assert_receive {:counter, %{count: 0}}
    assert {:ok, 1} = PageState.update_counter(id, "increment")
    assert_receive {:counter, %{count: 1}}
    assert {:ok, 0} = PageState.update_counter(id, "reset")
    assert_receive {:counter, %{count: 0}}
  end

  test "termination loses ephemeral state and next access starts fresh", %{session_id: id} do
    assert {:ok, pid} = PageState.ensure_session(id)
    monitor = Process.monitor(pid)
    assert {:ok, 1} = PageState.update_counter(id, "increment")
    assert :ok = SessionProcess.terminate(id)
    assert_receive {:DOWN, ^monitor, :process, ^pid, _reason}
    assert {:ok, new_pid} = PageState.ensure_session(id)
    refute new_pid == pid
    assert {:ok, 0} = PageState.read_counter(id)
  end

  test "concurrent first visits share one session process", %{session_id: id} do
    results =
      1..8
      |> Task.async_stream(fn _ -> PageState.ensure_session(id) end, max_concurrency: 8)
      |> Enum.map(fn {:ok, {:ok, pid}} -> pid end)

    assert [pid] = Enum.uniq(results)
    assert Process.alive?(pid)
    assert {:ok, 0} = PageState.read_counter(id)
  end

  test "concurrent interactions do not lose increments", %{session_id: id} do
    assert {:ok, _pid} = PageState.ensure_session(id)

    results =
      1..24
      |> Task.async_stream(fn _ -> PageState.update_counter(id, "increment") end,
        max_concurrency: 8
      )
      |> Enum.to_list()

    assert Enum.all?(results, fn
             {:ok, {:ok, count}} -> is_integer(count) and count in 1..24
             _ -> false
           end)

    assert {:ok, 24} = PageState.read_counter(id)
  end

  test "reset affects only the owning browser session", %{session_id: id} do
    other_id = SessionProcess.SessionId.generate_unique_session_id()
    on_exit(fn -> SessionProcess.terminate(other_id) end)
    assert {:ok, _pid} = PageState.ensure_session(id)
    assert {:ok, _pid} = PageState.ensure_session(other_id)
    assert {:ok, 1} = PageState.update_counter(id, "increment")
    assert {:ok, 1} = PageState.update_counter(other_id, "increment")
    assert {:ok, 0} = PageState.update_counter(id, "reset")
    assert {:ok, 1} = PageState.read_counter(other_id)
  end

  test "idle expiry removes state through the cleanup lifecycle", %{session_id: id} do
    old_ttl = Application.fetch_env!(:phoenix_session_process, :session_ttl)
    Application.put_env(:phoenix_session_process, :session_ttl, 50)
    on_exit(fn -> Application.put_env(:phoenix_session_process, :session_ttl, old_ttl) end)
    assert {:ok, pid} = PageState.ensure_session(id)
    monitor = Process.monitor(pid)
    Process.sleep(80)
    # The sweep also handles a per-session timer landing exactly at the TTL boundary.
    send(SessionProcess.Cleanup, :cleanup)
    assert_receive {:DOWN, ^monitor, :process, ^pid, _reason}, 1_000
    refute SessionProcess.started?(id)
  end
end
