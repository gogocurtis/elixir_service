
defmodule ElixirService.DnsController do
  use ElixirService.Web, :controller

  def check_mx(conn, %{"mailhost" => mailhost }) do
    result = ExDnsClient.lookup(mailhost,[{:type, :mx}])
    if length(result) > 0 do
      json conn, %{valid_mx: true }
    else
      json conn, %{valid_mx: false }

    end

  end
end
