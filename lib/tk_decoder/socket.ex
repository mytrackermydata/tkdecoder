defmodule TkDecoder.Socket do
  @moduledoc """
  TCP socket to handle incoming data
  """
  use GenServer

  require Logger

  alias TkDecoder.Dispatcher

  def start_link(opts) do
    ip = Application.get_env(:socket, :ip, {127, 0, 0, 1})
    port = Application.get_env(:socket, :port, 6666)

    Logger.info("Starting #{__MODULE__}")
    Logger.info("Listening on #{Enum.join(Tuple.to_list(ip), ".")}:#{port}")

    GenServer.start_link(__MODULE__, [ip, port], [] ++ opts)
  end

  def init([ip, port]) do
    {:ok, listen_socket} =
      :gen_tcp.listen(port, [:binary, packet: 0, active: true, reuseaddr: true, ip: ip])

    {:ok, socket} = :gen_tcp.accept(listen_socket)
    {:ok, %{ip: ip, port: port, socket: socket}}
  end

  def handle_info({:tcp, socket, packet}, state) do
    Logger.info("Received: #{packet}")

    case Dispatcher.dispatch(packet) do
      {:reply, response, data} ->
        :gen_tcp.send(socket, response)
        Logger.info("Protocol data: #{inspect(data)}")
        Logger.info("Response: #{response}")

      {:noreply, data} ->
        Logger.info("Protocol data: #{inspect(data)}")
        nil
    end

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    Logger.info("Socket has been closed")
    {:noreply, state}
  end

  def handle_info({:tcp_error, socket, reason}, state) do
    Logger.info(socket, label: "connection closed due to #{reason}")
    {:noreply, state}
  end
end
