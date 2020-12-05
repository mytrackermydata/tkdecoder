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

      iex> TkDecoder.Protocol.Link.decode(%Protocol{content: [], content_type: "LK", firm: "SG", device_id: "ABCDE"})
      {:reply, "[SG*ABCDE*0002*LK]", %Protocol{content: [], content_type: "LK", firm: "SG", device_id: "ABCDE"}}

      iex> TkDecoder.Protocol.Link.decode(%Protocol{content: [1, 100], content_type: "LK", firm: "SG", device_id: "ABCDE"})
      {:reply, "[SG*ABCDE*0002*LK]", %Protocol{content: [1, 100], content_type: "LK", firm: "SG", device_id: "ABCDE", battery: 100, steps: 1}}

  """
  def decode(%Protocol{content: [], content_type: type} = headers),
    do: {:reply, Protocol.make_response(headers, type), headers}

  def decode(%Protocol{content: [steps, battery], content_type: type} = headers),
    do:
      {:reply, Protocol.make_response(headers, type), %{headers | steps: steps, battery: battery}}

  def decode(%Protocol{content: [steps, battery, acc], content_type: type} = headers),
    do:
      {:reply, Protocol.make_response(headers, type),
       %{headers | steps: steps, battery: battery, acc: acc}}
end
