defmodule TkDecoder.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {DynamicSupervisor,
       strategy: :one_for_one, name: TkDecoder.Socket.Handler.DynamicSupervisor},
      {Task, fn -> TkDecoder.Socket.accept(Application.fetch_env!(:tkdecoder, :socket)) end}
    ]

    opts = [strategy: :one_for_one, name: TkDecoder.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
