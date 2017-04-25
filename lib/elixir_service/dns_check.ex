defmodule ElixirService.DnsCheck do
  def valid?(host) do
    result = ExDnsClient.lookup(host,[{:type, :mx}])
    %{ valid_mx: length(result) > 0 }
  end
end
