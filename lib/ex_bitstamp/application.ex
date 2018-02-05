defmodule ExBitstamp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    # TODO Pass in credentials here, so application can be started per user
    children = [
      # Starts a worker by calling: ExBitstamp.Worker.start_link(arg)
      # {ExBitstamp.Worker, arg},
      {Registry, keys: :unique, name: Registry.ExBitstamp}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExBitstamp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
