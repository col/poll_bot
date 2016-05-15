defmodule PollBot do
  use Application

  def version do
    {:ok, version} = :application.get_key(:poll_bot, :vsn)
    version
  end

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [worker(PollBot.Worker, [])]
    opts = [strategy: :one_for_one, name: PollBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
