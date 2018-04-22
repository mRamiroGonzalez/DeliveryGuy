
use Mix.Config

config :logger,
       backends: [:console],
       compile_time_purge_level: :error

config :deliveryguy, httpclient: Httpclient.Httpoison
