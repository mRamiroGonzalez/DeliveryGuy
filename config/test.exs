
use Mix.Config

config :logger,
       backends: [:console],
       compile_time_purge_level: :debug

config :deliveryguy, httpclient: Httpclient.Mock