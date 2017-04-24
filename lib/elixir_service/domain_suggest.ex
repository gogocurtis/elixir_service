defmodule ElixirService.DomainSuggest do
  import DefMemo
  def suggest(host, domain_list \\ white_list()) do
    suggestion_map = filter_suggestions(suggestions(domain_list, host), 1)
    suggestions =  Map.keys(suggestion_map)
    if length(suggestions) > 0 do
      %{ hasSuggestion: true , suggestion: List.first(suggestions)}
    else
      %{ hasSuggestion: false }
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
