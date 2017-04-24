
defmodule ElixirService.DnsController do
  use ElixirService.Web, :controller

  def check_mx(conn, %{"email" => email }) do
    conn
    |> json(ElixirService.MailCheck.check(email))
  end

  # fall-through case
  def check_mx(conn, _params) do
    conn
    |>  put_status(422)
    |>  json(%{"errors" => ["invalid params"]})
  end
end
