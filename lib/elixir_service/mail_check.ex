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

    # this and
    valid = DnsCheck.valid?(host)
    # this can be done in parallel
    suggestion = DomainSuggest.suggest(host)

    # build the respons based on the best information resolved before
    # the timeout occurs
    #
    Map.merge(%MailCheck{hostname: host,
                         valid_mx: valid
                        }, suggestion)
  end
end
