defmodule TkDecoder.Socket.Handler do
  use GenServer
  require Logger

  alias TkDecoder.{Dispatcher, Protocol}

  def start_link(args, options) do
    GenServer.start_link(__MODULE__, args, options)
  end

  @impl true
  def init(args) do
    socket = Map.get(args, :socket)
    :inet.setopts(socket, active: true)
    {:ok, %{socket: socket, device_id: nil}}
  end

  @impl true
  def handle_info({:tcp, socket, packet}, state) do
    Logger.info("Received: #{packet}")
    Logger.info("State: #{inspect(state)}")

    try do
      case Dispatcher.dispatch(packet) do
        {:reply, response, %Protocol{device_id: device_id} = data} ->
          :gen_tcp.send(socket, response)
          Logger.info("Protocol data: #{inspect(data)}")
          Logger.info("Response: #{response}")
          {:noreply, %{state | device_id: device_id}}

        {:noreply, %Protocol{device_id: device_id} = data} ->
          Logger.info("Protocol data: #{inspect(data)}")
          {:noreply, %{state | device_id: device_id}}
      end
    rescue
      e ->
        Logger.error("Error: #{inspect(e)}")
        {:noreply, state}
    end
  end

  @impl true
  def handle_info({:tcp_closed, _socket}, state) do
    Logger.info("Socket is closed")
    {:stop, {:shutdown, "Socket is closed"}, state}
  end

  @impl true
  def handle_info({:tcp_error, _socket, reason}, state) do
    Logger.error("TCP Socket error: #{inspect(reason)}")
    {:stop, {:shutdown, "Tcp error: #{inspect(reason)}"}, state}
  end
end
