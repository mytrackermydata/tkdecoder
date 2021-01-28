defmodule TkDecoder.Protocol.Link do
  @moduledoc """
  Link is a sort of keep-alive packet.
  Link packets include steps, battery and acc (only for TK806).
  TK devices requires a response to keep the socket alive.
  """
  alias TkDecoder.Protocol

  @doc ~S"""
  Parse device info and send response

  ## Examples

      iex> TkDecoder.Protocol.Link.decode(%{content: [], content_type: "LK", firm: "SG", device_id: "ABCDE"})
      {:ok, %{content: [], content_type: "LK", firm: "SG", device_id: "ABCDE"}}

      iex> TkDecoder.Protocol.Link.decode(%{content: [1, 100], content_type: "LK", firm: "SG", device_id: "ABCDE"})
      {:ok, %{content: [1, 100], content_type: "LK", firm: "SG", device_id: "ABCDE", battery: 100, steps: 1}}

  """
  def decode(%{content: []} = headers),
    do: send(headers)

  def decode(%{content: [steps, battery]} = headers),
    do:
      send(%{headers | steps: steps, battery: battery})

  def decode(%{content: [steps, battery, acc]} = headers),
    do:
       send(%{headers | steps: steps, battery: battery, acc: acc})

  defp send(decoded_data), do: {:ok, decoded_data}

  def reply(%{content_type: type} = headers), do: {:reply, Protocol.make_response(headers, type)}
end
