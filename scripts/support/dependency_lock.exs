defmodule Gsmlg.DependencyLock do
  @moduledoc false

  # This preflight deliberately checks only direct Hex dependencies. Mix still
  # owns transitive resolution, checksums, fetching, and lockfile generation.
  def errors(dependencies, lock) do
    Enum.flat_map(dependencies, fn dependency ->
      {app, requirement, options} = normalize(dependency)

      if Enum.any?([:path, :git, :github], &Keyword.has_key?(options, &1)) do
        []
      else
        check(app, requirement, Keyword.get(options, :hex, app), Map.get(lock, app))
      end
    end)
  end

  defp normalize({app, requirement}) when is_binary(requirement),
    do: {app, requirement, []}

  defp normalize({app, options}) when is_list(options), do: {app, nil, options}
  defp normalize({app, requirement, options}), do: {app, requirement, options}

  defp check(app, _requirement, _package, nil),
    do: ["#{app}: missing from mix.lock"]

  defp check(app, requirement, package, entry)
       when is_tuple(entry) and tuple_size(entry) >= 3 and elem(entry, 0) == :hex do
    locked_package = elem(entry, 1)
    version = elem(entry, 2)

    cond do
      to_string(locked_package) != to_string(package) ->
        ["#{app}: mix.lock names #{locked_package}, expected #{package}"]

      is_nil(requirement) or Version.match?(version, requirement) ->
        []

      true ->
        ["#{app}: locked #{version} does not satisfy #{requirement}"]
    end
  end

  defp check(app, _requirement, _package, _entry),
    do: ["#{app}: expected a Hex entry in mix.lock"]
end
