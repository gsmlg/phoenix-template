defmodule GsmlgWeb.PageControllerTest do
  use GsmlgWeb.ConnCase

  test "GET / renders the starter page", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "A clear foundation for your next web system."
  end
end
