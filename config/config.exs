# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :hello_phoenix, HelloPhoenix.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "qZGX7OUzlYtm0QDc34NZoyON1ir1znBfePlJsThS6Eqn+c+WtDi1j204VAj1hJ99",
  #render_errors: [default_format: "html"],
  render_errors: [accepts: ["html"]],
  pubsub: [name: HelloPhoenix.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

#exometer
#app_name         = :my_webapp
#polling_interval = 1_000
#histogram_stats  = ~w(min max mean 95 90)a
#memory_stats     = ~w(atom binary ets processes total)a
#
#config :exometer,
#  predefined:
#    [
#      {
#        ~w(erlang memory)a,
#        {:function, :erlang, :memory, [], :proplist, memory_stats},
#        []
#      },
#      {
#        ~w(erlang statistics)a,
#        {:function, :erlang, :statistics, [:'$dp'], :value, [:run_queue]},
#        []
#      },
#      {
#        [app_name, :webapp, :resp_time],
#        :histogram,
#        [truncate: false]
#      },
#      {
#        [app_name, :webapp, :resp_count],
#        :spiral,
#        []
#      },
#    ],
#
#  reporters:
#    [
#      exometer_report_tty:
#      [],
#    ],
#
#  report: 
#    [
#      subscribers:
#      [
#        {
#          :exometer_report_tty,
#          [app_name, :webapp, :resp_time], histogram_stats, polling_interval, true
#        },
#        {
#          :exometer_report_tty,
#          [:erlang, :memory], memory_stats, polling_interval, true
#        },
#        {
#          :exometer_report_tty,
#          [app_name, :webapp, :resp_count], :one, polling_interval, true
#        },
#        {
#          :exometer_report_tty,
#          [:erlang, :statistics], :run_queue, polling_interval, true
#        },
#      ]
#  ]



