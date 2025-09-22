defmodule TheMastermind.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Application.put_env(:elixir, :ansi_enabled, true)

    bot_options = %{
      name: "The Mastermind",
      consumer: TheMastermind.Consumer,
      intents: :all,
      wrapped_token: fn -> Application.get_env(:the_mastermind, :discord_token) end
    }

    children = [
      TheMastermindWeb.Telemetry,
      TheMastermind.Repo,
      {DNSCluster, query: Application.get_env(:the_mastermind, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TheMastermind.PubSub},
      # Start a worker by calling: TheMastermind.Worker.start_link(arg)
      # {TheMastermind.Worker, arg},
      # Start to serve requests, typically the last entry
      TheMastermindWeb.Endpoint,

      {Nosedrum.Storage.Dispatcher, name: Nosedrum.Storage.Dispatcher},
      {Nostrum.Bot, bot_options},
      {Cachex, :cache}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TheMastermind.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TheMastermindWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
