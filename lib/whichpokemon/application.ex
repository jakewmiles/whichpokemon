defmodule Whichpokemon.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Whichpokemon.Repo,
      # Start the Telemetry supervisor
      WhichpokemonWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Whichpokemon.PubSub},
      # Start the Endpoint (http/https)
      WhichpokemonWeb.Endpoint
      # Start a worker by calling: Whichpokemon.Worker.start_link(arg)
      # {Whichpokemon.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Whichpokemon.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WhichpokemonWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
