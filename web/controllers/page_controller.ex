defmodule ElixirService.PageController do
  use ElixirService.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
