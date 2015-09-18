defmodule HelloPhoenix do
  use Application
  use Amnesia

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Amnesia.start #I feel I should stop this at some point or its going to bite me...
    #UpdateBullets will call !broadcast to all clients...ah...yeah!?
    :timer.apply_interval(30, UpdateBullets, :tick, [])

    children = [
      # Start the endpoint when the application starts
      supervisor(HelloPhoenix.Endpoint, []),
      # Start the Ecto repository
      worker(HelloPhoenix.Repo, []),
      # Here you could define other workers and supervisors as children
      # worker(HelloPhoenix.Worker, [arg1, arg2, arg3]),
      # worker(HelloPhoenix.Redis, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HelloPhoenix.Supervisor]
    Supervisor.start_link(children, opts)
   
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    HelloPhoenix.Endpoint.config_change(changed, removed)
    :ok
  end
end