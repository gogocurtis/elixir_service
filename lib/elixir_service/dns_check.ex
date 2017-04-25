defmodule ElixirService.DnsCheck do
  def valid?(host) do
    result = ExDnsClient.lookup(host,[{:type, :mx}])
    %{ validMx: length(result) > 0 }
  end
end
