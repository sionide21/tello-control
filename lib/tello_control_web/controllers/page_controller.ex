defmodule TelloControlWeb.PageController do
  use TelloControlWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
