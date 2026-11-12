defmodule Gsmlg.Assets.DuskmoonBundlerWatcher do
  @moduledoc false

  def run(opts) when is_list(opts) do
    {profile_name, overrides} = Keyword.pop(opts, :profile, :gsmlg)

    opts =
      Gsmlg.Assets.watcher_options(
        Application.fetch_env!(:duskmoon_bundler, profile_name),
        Application.get_all_env(:duskmoon_bundler),
        overrides
      )

    case DuskmoonBundler.Watcher.start_link(opts) do
      {:ok, _pid} -> Process.sleep(:infinity)
      {:error, {:already_started, _pid}} -> Process.sleep(:infinity)
      {:error, reason} -> raise "failed to start DuskmoonBundler watcher: #{inspect(reason)}"
    end
  end
end
