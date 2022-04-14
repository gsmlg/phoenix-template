defmodule GsmlgWeb.PageController do
  use GsmlgWeb, :controller

  def index(conn, _params) do
    conn
    |> render("index.html")
  end

  def not_found(conn, _params) do
    conn
    |> render("index.html")
  end
end
