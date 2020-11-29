defmodule TkDecoder.Protocol.Custom do
  def decode(headers), do: {:noreply, headers}
end
