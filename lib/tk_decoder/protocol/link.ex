defmodule TkDecoder.Protocol.Link do
  alias TkDecoder.Protocol

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
