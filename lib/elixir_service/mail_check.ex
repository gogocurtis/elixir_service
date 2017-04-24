defmodule ElixirService.MailCheck do
  defstruct [:hostname, :valid_mx, :has_suggestion, :suggestion]

  alias ElixirService.DomainSuggest
  alias ElixirService.MailCheck
  alias ElixirService.DnsCheck
  def extract_domain(email) do
    List.last(String.split(email,"@"))
  end

  def check(email) do
    host  = extract_domain(email)
    valid = DnsCheck.valid?(host)

    suggestion = DomainSuggest.suggest(host)

    Map.merge(%MailCheck{hostname: host,
                         valid_mx: valid
                        }, suggestion)
  end
end
