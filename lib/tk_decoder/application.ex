defmodule TkDecoder.Application do
  @moduledoc false

  use Application

  alias Amqpx.Helper

  def start(_type, _args) do
    children = [
      {DynamicSupervisor,
       strategy: :one_for_one, name: TkDecoder.Socket.Handler.DynamicSupervisor},
      {Task, fn -> TkDecoder.Socket.accept(Application.fetch_env!(:tkdecoder, :socket)) end},
      Helper.manager_supervisor_configuration(Application.get_env(:tkdecoder, :amqp_connection)),
      Helper.producer_supervisor_configuration(Application.get_env(:tkdecoder, :producer))
    ]

    opts = [strategy: :one_for_one, name: TkDecoder.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
