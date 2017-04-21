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
  
  # https://en.wikipedia.org/wiki/Levenshtein_distance
  def edit_distance(sequence, sequence), do: 0
  
  def edit_distance([], sequence), do: length(sequence)
  
  def edit_distance(sequence, []), do: length(sequence)
  
  def edit_distance([source_head | source_tail], [source_head | target_tail]) do  
    edit_distance(source_tail, target_tail) 
  end
  
  def edit_distance([source_head | source_tail], [target_head | target_tail]) do
    Enum.min([
       # Deletion 
       1 + edit_distance(source_tail, [target_head | target_tail]),
       # Insertion
       1 + edit_distance([source_head | source_tail], target_tail),
       # Subsitution
       1 + edit_distance(source_tail, target_tail),
    ]) 
  end
end

defmodule ElixirService.DnsController do
  use ElixirService.Web, :controller


  def check_mx(conn, %{}) do
    conn
    |>  put_status(422)
    |>  json(%{"errors" => ["invalid params"]})
  end

  def check_mx(conn, %{"email" => email }) do
    conn
    |> json(MailCheck.check(email))
  end
end
