defmodule TkDecoder.Dispatcher do
  @moduledoc """
  Dispath incoming data to correct protocol handler
  """

  alias TkDecoder.Protocol

  def dispatch(data) do
    data
    |> String.replace("[", "")
    |> String.replace("]", "")
    |> String.replace("\n", "")
    |> extract_headers!()
    |> extract_content!()
  end

  defp extract_headers!(data) do
    [firm, device_id, lenght, content] = String.split(data, "*")

    device =
      ~r/^[0-9]{3}/
      |> Regex.run(device_id)
      |> List.first()

    %Protocol{firm: firm, device: device, device_id: device_id, lenght: lenght, content: content}
  end

  defp extract_content!(%Protocol{content: content} = headers) do
    content
    |> String.split(",")
    |> Protocol.get_content_type(headers)
    |> call_decode()
  end

  defp call_decode({call, module}) do
    apply(module, :decode, [call])
  end
end
