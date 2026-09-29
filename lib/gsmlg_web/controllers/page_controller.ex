defmodule GsmlgWeb.PageController do
  use GsmlgWeb, :controller

  def home(conn, _params), do: render(conn, :home)
end
