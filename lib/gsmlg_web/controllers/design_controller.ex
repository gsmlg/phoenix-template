defmodule GsmlgWeb.DesignController do
  use GsmlgWeb, :controller

  def download(conn, _params) do
    conn
    |> put_resp_header("x-design-spec-sha256", Gsmlg.DesignSpec.fingerprint())
    |> send_download({:binary, Gsmlg.DesignSpec.markdown()},
      filename: "DESIGN.md",
      content_type: "text/markdown; charset=utf-8"
    )
  end

  def legacy_ui(conn, _params), do: redirect(conn, to: ~p"/use-cases")
end
