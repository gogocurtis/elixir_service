defmodule ElixirService.Endpoint do
  use Phoenix.Endpoint, otp_app: :elixir_service

  socket "/socket", ElixirService.UserSocket

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :elixir_service, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_elixir_service_key",
    signing_salt: "RRvbJb1l"

  plug ElixirService.Router

  def get_env_or_raise(var) do
    System.get_env(var) || raise "expected #{var} environment variable to be set"
  end

  def get_env_or_default(var,default) do
    System.get_env(var) || default
  end

  def load_from_system_env(config) do
    port = get_env_or_raise("PORT")
    host = get_env_or_raise("HOST")
    check_origin = String.split(get_env_or_default("CHECK_ORIGIN", "http://localhost:8000"),",")
    secret_key   = get_env_or_default("SECRET_KEY_BASE", :crypto.strong_rand_bytes(64) |> Base.encode64)
    #   http: [port: {:system, "PORT"}],
    #     url:  [host: {:system, "DOCKERCLOUD_SERVICE_FQDN"},
    #            port: {:system, "PORT"}],
    #     check_origin: ["http://localhost:8000"],
    sys_config = config
    |> Keyword.put(:http, [port: port])
    |> Keyword.put(:url, [host: host, port: port])
    |> Keyword.put(:secret_key_base, secret_key)
    |> Keyword.put(:check_origin, check_origin)

    {:ok, sys_config }
  end
end
