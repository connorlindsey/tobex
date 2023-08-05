defmodule Tobex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      TobexWeb.Telemetry,
      # Start the Ecto repository
      Tobex.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Tobex.PubSub},
      # Start Finch
      {Finch, name: Tobex.Finch},
      # Start the Endpoint (http/https)
      TobexWeb.Endpoint
      # Start a worker by calling: Tobex.Worker.start_link(arg)
      # {Tobex.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tobex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TobexWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
