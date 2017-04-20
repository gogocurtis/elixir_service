defmodule MailCheck do
  defstruct [:hostname, :valid_mx, :has_suggestion, :suggestion]

  def extract_domain(email) do
    List.last(String.split(email,"@"))
  end

  def check(email) do
    host = extract_domain(email)
    add_suggestion(
      %MailCheck{hostname: host, valid_mx: valid?(host)},
      host
    )
  end

  def add_suggestion(check, host) do
    suggestion_for(check,host)
  end

  def suggestion_for(check, host) do
    distance = 1
    suggested_host = "gmail.com"
   %{ check | has_suggestion: 1 == distance, suggestion: suggested_host}
  end

  def valid?(host) do
    result = ExDnsClient.lookup(host,[{:type, :mx}])
    if length(result) > 0 do
      true
    else
      false
    end
  end
end

defmodule ElixirService.DnsController do
  use ElixirService.Web, :controller


  def check_mx(conn, %{"email" => email }) do
      json conn, MailCheck.check(email)
  end
end
