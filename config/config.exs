use Mix.Config

config :tkdecoder, :socket,
  ip: {0, 0, 0, 0},
  port: 4444

config :tkdecoder,
  amqp_connection: [
    username: "tkdecoder",
    password: "tkdecoder",
    host: "rabbit",
    virtual_host: "/",
    heartbeat: 30,
    connection_timeout: 10_000
  ]

config :tkdecoder, :producer, %{
  publisher_confirms: false,
  publish_timeout: 0,
  exchanges: [
    %{name: "gps", type: :fanout, opts: [durable: true]}
  ]
}
