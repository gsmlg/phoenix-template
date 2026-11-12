defmodule Gsmlg.TestDatabaseConfigTest do
  use ExUnit.Case, async: false

  @variables ~w(PGDATABASE PGDATABASE_TEST MIX_TEST_PARTITION)

  setup do
    original = Map.new(@variables, &{&1, System.get_env(&1)})
    Enum.each(@variables, &System.delete_env/1)

    on_exit(fn ->
      Enum.each(original, fn
        {key, nil} -> System.delete_env(key)
        {key, value} -> System.put_env(key, value)
      end)
    end)
  end

  test "does not target the development database through PGDATABASE" do
    System.put_env("PGDATABASE", "important_development_data")
    assert database() == "gsmlg_test"
  end

  test "honors a separate test database and preserves partition isolation" do
    System.put_env("PGDATABASE_TEST", "custom_test")
    System.put_env("MIX_TEST_PARTITION", "3")
    assert database() == "custom_test3"
  end

  defp database do
    Path.expand("../../config/config.exs", __DIR__)
    |> Config.Reader.read!(env: :test, target: :host)
    |> Keyword.fetch!(:gsmlg)
    |> Keyword.fetch!(Gsmlg.Repo)
    |> Keyword.fetch!(:database)
  end
end
