use Mix.Config

config :poll_bot, token: (System.get_env("POLL_BOT_TOKEN") || "")

config :poll_bot, bot_hub_node: "bot_hub@bothub"

import_config "#{Mix.env}.exs"
