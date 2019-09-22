# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :exile,
  ecto_repos: [Exile.Repo]

config :exile_web,
  ecto_repos: [Exile.Repo],
  generators: [context_app: :exile]

config :exile_auth,
  ecto_repos: [ExileAuth.Repo],
  generators: [context_app: :exile_auth]

# Configures the endpoint
config :exile_web, ExileWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "zHGkHhadYHTeJLFoyelM6pB31vYPVkVybIcGvfvqD4xNyX/fA6VTxiyQNnyA2elX",
  render_errors: [view: ExileWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ExileWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure Guardian secret for generating JWTs
config :exile_auth, ExileAuth.Guardian,
  issuer: "exile_auth",
  secret_key: "yYSAJxjltNf3Acl0FjsDjD0yp0X5kLGev4z2eTR2TLaKoURCJsdowKSVbniohREn"

import_config "#{Mix.env()}.exs"

if File.exists?(Path.join([__DIR__, "#{Mix.env()}.secret.exs"])) do
  import_config "#{Mix.env()}.secret.exs"
end
