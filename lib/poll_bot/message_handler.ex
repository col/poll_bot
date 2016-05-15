defmodule PollBot.MessageHandler do
  alias PollBot.Poll
  
  def handle_message(%{command: "/newpoll", params: params}, poll) do
    poll = %Poll{title: Enum.join(params, " ")}
    {poll, "New Poll: #{poll.title}"}
  end

  def handle_message(%{command: "/options", params: params}, poll) do
    options = Enum.join(params, " ")
      |> String.split(",")
      |> Enum.reduce([], fn(o, a) -> [String.strip(o)|a] end)

    poll = Poll.add_options(poll, options)
    {poll, "Added poll options: #{Enum.join(options, "")}"}
  end

  def handle_message(%{command: "/done"}, poll) do
    {poll, Poll.format(poll)}
  end

  def handle_message(%{command: "/vote", params: params, from: user}, poll) do
    option = Enum.join(params, " ")
    case Poll.add_response_for(poll, option, user.id) do
      {:ok, poll} -> {poll, "#{user.first_name} voted for #{option}"}
      {:option_not_found} -> {poll, "#{option} is not a valid option"}
    end
  end

  def handle_message(%{command: "/poll"}, poll) do
    {poll, Poll.format(poll, votes: true)}
  end
end
