defmodule ElixirService.MailCheck do
  defstruct [:hostname, :email ,:validMx, :hasSuggestion, :suggestion, :error]

  @doc """
  Starts the registry with the given `name`.
  """
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    {:ok, nil}
  end

  alias ElixirService.DomainSuggest
  alias ElixirService.MailCheck
  alias ElixirService.DnsCheck

  def extract_domain(email) do
    List.last(String.split(email,"@"))
  end

  def check(email) do
    host = extract_domain(email)
    results = perform(tasks(host),1900)

    case results do
      {:ok, result} ->
        Enum.reduce(result, %MailCheck{hostname: host, email: email} ,fn(el,acc) ->
          Map.merge(acc,el)
        end)
      {:timeout, _} ->
        %MailCheck{error: "timeout"}
      _ ->
        %MailCheck{error: "timeout"}
    end
  end

  def perform(tasks, timeout) do
    Enum.map(Task.yield_many(tasks, timeout),
      fn {task, response} -> response || {:timeout, Task.shutdown(task, :brutal_kill)} end
    ) |> Enum.group_by(
      fn(el) -> elem(el,0) end,
      fn(el) -> elem(el,1) end
    ) |> Map.to_list
      |> List.first
  end

  def tasks(host) do
    [Task.async(fn -> DnsCheck.valid?(host) end),
      Task.async(fn -> DomainSuggest.suggest(host) end)]
  end
end
