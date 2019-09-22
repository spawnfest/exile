use Mix.Config

config :exile_web, ExileWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../apps/exile_web/assets", __DIR__)
    ]
  ]

config :exile_web, ExileWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/exile_web/{live,views}/.*(ex)$",
      ~r"lib/exile_web/templates/.*(eex)$"
    ]
  ]

config :logger, :console, format: "[$level] $message\n"
config :phoenix, :plug_init_mode, :runtime
config :phoenix, :stacktrace_depth, 20
