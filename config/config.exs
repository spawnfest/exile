use Mix.Config

config :exile_web,
  generators: [context_app: :exile]

config :exile_web, ExileWeb.Endpoint,
  url: [host: "localhost"],
  live_view: [signing_salt: "IG9Dv+0Y"],
  secret_key_base: "zHGkHhadYHTeJLFoyelM6pB31vYPVkVybIcGvfvqD4xNyX/fA6VTxiyQNnyA2elX",
  render_errors: [view: ExileWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ExileWeb.PubSub, adapter: Phoenix.PubSub.PG2]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason
import_config "#{Mix.env()}.exs"

if File.exists?(Path.join([__DIR__, "#{Mix.env()}.secret.exs"])) do
  import_config "#{Mix.env()}.secret.exs"
end
