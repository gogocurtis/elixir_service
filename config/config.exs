# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :mix_docker, image: "dockergogo/el_service_docker"

# Configures the endpoint
config :elixir_service, ElixirService.Endpoint,
  secret_key_base: "ML4nltTCdy5ZGttTs9BokhZorOw+DQdRbiIElzDr3isRFeIVk3BQ7IugfbVGPjuZ",
  render_errors: [view: ElixirService.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ElixirService.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
