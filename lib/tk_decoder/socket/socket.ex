defmodule TkDecoder.Socket do
  @moduledoc """
  TCP socket to handle incoming data
  """

  require Logger
  alias TkDecoder.Socket.Handler

  def accept(ip: ip, port: port) do
    {:ok, socket} =
      :gen_tcp.listen(port, [:binary, packet: 0, active: false, reuseaddr: true, ip: ip])

    Logger.info("Accepting connections on #{inspect(ip)}:#{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    Logger.info("Accepted new connection")

    {:ok, pid} =
      DynamicSupervisor.start_child(Handler.DynamicSupervisor, %{
        id: Handler,
        start: {Handler, :start_link, [%{socket: client}, []]},
        type: :worker
      })

    :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end
end
