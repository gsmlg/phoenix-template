defmodule Gsmlg.RuntimeRequirements do
  @moduledoc "Checks the runtime versions required by the template and DuskMoon Hologram."

  @spec validate(String.t(), String.t()) :: :ok | {:error, String.t()}
  def validate(elixir_version, otp_release) do
    with {:ok, version} <- Version.parse(elixir_version),
         true <- Version.match?(version, ">= 1.18.0"),
         {otp, ""} when otp >= 28 <- Integer.parse(otp_release) do
      :ok
    else
      _ -> {:error, "Phoenix Template requires Elixir >= 1.18.0 and Erlang/OTP >= 28"}
    end
  end

  @spec check!() :: :ok
  def check! do
    case validate(System.version(), System.otp_release()) do
      :ok -> :ok
      {:error, message} -> raise message
    end
  end
end
