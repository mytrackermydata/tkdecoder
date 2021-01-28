defmodule TkDecoder.Protocol.Custom do
  def decode(headers), do: {:ok, headers}
  def reply(headers), do: {:noreply, headers}
end
