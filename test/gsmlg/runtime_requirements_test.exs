defmodule Gsmlg.RuntimeRequirementsTest do
  use ExUnit.Case, async: true

  alias Gsmlg.RuntimeRequirements

  test "accepts the minimum and newer stable runtimes" do
    assert :ok = RuntimeRequirements.validate("1.18.0", "28")
    assert :ok = RuntimeRequirements.validate("1.19.0", "29")
  end

  test "rejects older Elixir or OTP independently" do
    assert {:error, _} = RuntimeRequirements.validate("1.17.3", "28")
    assert {:error, _} = RuntimeRequirements.validate("1.18.4", "27")
  end

  test "rejects malformed version values" do
    assert {:error, _} = RuntimeRequirements.validate("unknown", "28")
    assert {:error, _} = RuntimeRequirements.validate("1.18.4", "28junk")
  end

  test "the running toolchain meets the requirements" do
    assert :ok = RuntimeRequirements.check!()
  end
end
