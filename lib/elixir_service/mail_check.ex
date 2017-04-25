defmodule ElixirService.MailCheck do
  defstruct [:hostname, :validMx, :hasSuggestion, :suggestion, :email]

  alias ElixirService.DomainSuggest
  alias ElixirService.MailCheck
  alias ElixirService.DnsCheck
  def extract_domain(email) do
    List.last(String.split(email,"@"))
  end

  def check(email) do
    host  = extract_domain(email)

    # TODO : production code requirement
    # this and
    valid = DnsCheck.valid?(host)
    # this can be done in parallel
    suggestion = DomainSuggest.suggest(host)

    # build the respons based on the best information resolved before
    # the timeout occurs
    #
    Map.merge(%MailCheck{
          email: email,
          hostname: host,
          validMx: valid
              }, suggestion)
  end
end
