defmodule ElixirService.DnsCheck do
  def valid?(host) do
    result = ExDnsClient.lookup(host,[{:type, :mx}])
    if length(result) > 0 do
      true
    else
      false
    end
  end
end
