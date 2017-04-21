defmodule MailCheck do
  import DefMemo

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

  def suggestion_for(check, host, domain_list \\ white_list()) do
    suggestions = suggestions(domain_list, host)
    suggestions = filter_suggestions(suggestions, 1)
   %{ check | has_suggestion: map_size(suggestions) > 0, suggestion: suggestions}
  end

  def valid?(host) do
    result = ExDnsClient.lookup(host,[{:type, :mx}])
    if length(result) > 0 do
      true
    else
      false
    end
  end

  def filter_suggestions(suggestions, length) do
    suggestions
    |> Enum.filter(fn {_, v} -> v == length end)
    |> Enum.into(%{})
  end

  def suggestions(domain_list, host), do: suggestions(domain_list, host, %{})

  def suggestions([], _, accumulator), do: accumulator

  def suggestions([head | tail], host, accumulator) do
    accumulator = Map.put(accumulator,
        head,
        edit_distance(head, host)
    )
    suggestions(tail, host, accumulator)
  end

  def white_list, do: ["gmail.com", "yahoo.com", "hotmail.com"]

  # https://en.wikipedia.org/wiki/Levenshtein_distance
  defmemo edit_distance(sequence, sequence), do: 0

  defmemo edit_distance([], sequence), do: length(sequence)

  defmemo edit_distance(sequence, []), do: length(sequence)

  defmemo edit_distance([source_head | source_tail], [source_head | target_tail]) do
    edit_distance(source_tail, target_tail)
  end

  def edit_distance(source, target) when is_binary(source) do
    edit_distance(String.graphemes(source), target)
  end

  def edit_distance(source, target) when is_binary(target) do
    edit_distance(source, String.graphemes(target))
  end

  defmemo edit_distance([source_head | source_tail], [target_head | target_tail]) do
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

  def check_mx(conn, %{"email" => email }) do
    conn
    |> json(MailCheck.check(email))
  end

  # fall-through case
  def check_mx(conn, _params) do
    conn
    |>  put_status(422)
    |>  json(%{"errors" => ["invalid params"]})
  end
end
