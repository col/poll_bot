defmodule PollBot.Poll do
  defstruct [title: "", options: %{}]

  def set_title(poll, title) do
    Map.put(poll, :title, title)
  end

  def set_options(poll, options) do
    Map.put(poll, :options, options)
  end

  def add_options(poll, []), do: poll
  def add_options(poll, [option]), do: add_option(poll, option)
  def add_options(poll, [head|tail]) do
    poll = add_option(poll, head)
    add_options(poll, tail)
  end

  def add_option(poll, option) do
    case Map.has_key?(poll.options, option) do
      true -> poll
      false -> %{poll | options: Map.put(poll.options, option, [])}
    end
  end

  def remove_response(poll, user_id) do
    options = for {k, v} <- poll.options, into: %{}, do: {k, List.delete(v, user_id)}
    %{poll | options: options}
  end

  def add_response_for(poll, option, user_id) do
    case Map.get(poll.options, option) do
      nil -> {:option_not_found}
      votes ->
        poll = remove_response(poll, user_id)
        {:ok, %{poll| options: Map.put(poll.options, option, Enum.uniq([user_id|votes])) }}
    end
  end

  def format(poll, opts \\ []) do
    poll.options
      |> Enum.map(&line_for_option(&1, opts))
      |> List.insert_at(0, poll.title)
      |> Enum.join("\n")
  end

  def line_for_option({option, votes}, [votes: true]) do
    vote_count = Enum.count(votes)
    "- #{option}: #{vote_count} #{Inflex.inflect("vote", vote_count)}"
  end

  def line_for_option({option, _}, _) do
    "- #{option}"
  end


end
