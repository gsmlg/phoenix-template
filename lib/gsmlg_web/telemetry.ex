defmodule GsmlgWeb.Telemetry do
  import Telemetry.Metrics

  def metrics do
    [
      summary("phoenix.endpoint.stop.duration", unit: {:native, :millisecond}),
      summary("phoenix.router_dispatch.stop.duration", unit: {:native, :millisecond}),
      distribution("phoenix.socket_connected.duration", unit: {:native, :millisecond}),
      counter("phoenix.endpoint.stop.count")
    ]
  end
end
