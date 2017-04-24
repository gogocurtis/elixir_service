defmodule ElixirService.MailCheck do
  defstruct [:hostname, :valid_mx, :has_suggestion, :suggestion]

  def extract_domain(email) do
    List.last(String.split(email,"@"))
  end

  def check(email) do
    host = extract_domain(email)
    check = %ElixirService.MailCheck{hostname: host, valid_mx: ElixirService.DnsCheck.valid?(host)}
   
    ElixirService.DomainSuggest.add_suggestion(
      check,
      host
    )
  end
end
