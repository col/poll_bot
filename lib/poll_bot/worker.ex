defmodule PollBot.Worker do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, "PollBot")
  end

  def handle_message(pid, message) do
    GenServer.cast(pid, {:handle_message, message})
  end

  def init(name) do
    connect_to_hub
    :global.register_name(name, self)
    IO.puts "Registered Bot: #{name}"
    {:ok, %PollBot.Poll{}}
  end

  def connect_to_hub do
    node_name = Application.get_env(:poll_bot, :bot_hub_node)
    result = Node.connect String.to_atom(node_name)
    IO.puts "Connecting to bot_hub (#{node_name}): #{result}"
  end

  def token, do: Application.get_env(:poll_bot, :token)

  def handle_cast({:handle_message, json}, poll) do
    IO.puts "JSON: #{inspect json}"
    message = Telegram.Update.parse(json).message
    IO.puts "Message: #{inspect message}"

    {poll, response} = PollBot.MessageHandler.handle_message(message, poll)

    Nadia.send_message(message.chat.id, response, token: token)
    {:noreply, poll}
  end

  def handle_call(:version, _from, state) do
    {:reply, PollBot.version, state}
  end

end
