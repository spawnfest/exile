use Mix.Config

config :exile_web, ExileWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :warn
