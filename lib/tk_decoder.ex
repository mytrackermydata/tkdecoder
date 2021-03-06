defmodule TkDecoder do
  @moduledoc """
  Dispath incoming data to correct protocol handler
  """
  @behaviour Gateway.Parser

  alias TkDecoder.Protocol

  @doc ~S"""
  Receive incoming packets from socket and dispatch it to correct protocol handler

  ### Examples

      iex> TkDecoder.parse("[SG*0123456*0009*LK,0,80]")
      {:ok, "[SG*0123456*0002*LK]", %TkDecoder.Protocol{acc: nil, altitude: nil, battery: "80", content: ["0", "80"], content_type: "LK", device: "012", device_id: "0123456", device_timestamp: nil, direction: nil, firm: "SG", gsm_signal: nil, latitude: nil, latitude_mark: nil, lbs_stations: nil, lenght: "0009", located: nil, longitude: nil, longitude_mark: nil, roll: nil, satellites: nil, speed: nil, status: nil, steps: "0"}}

      iex> TkDecoder.parse("[SG*0123456*0009*LK,0,80,1]")
      {:ok, "[SG*0123456*0002*LK]", %TkDecoder.Protocol{acc: "1", altitude: nil, battery: "80", content: ["0", "80", "1"], content_type: "LK", device: "012", device_id: "0123456", device_timestamp: nil, direction: nil, firm: "SG", gsm_signal: nil, latitude: nil, latitude_mark: nil, lbs_stations: nil, lenght: "0009", located: nil, longitude: nil, longitude_mark: nil, roll: nil, satellites: nil, speed: nil, status: nil, steps: "0"}}

      iex> TkDecoder.parse("[SG*0123456*00BC*UD2,291120,160025,A,42.53534,N,14.14355,E,0.0000,214,1,08,100,70,0,50,00000000,6,1,222,10,30081,40593,160,30081,40591,147,30081,55812,142,30081,14461,138,30081,40691,137,30081,40692,135,,00]")
      {:ok, %TkDecoder.Protocol{acc: nil, altitude: "1", battery: "70", content: ["1", "222", "10", "30081", "40593", "160", "30081", "40591", "147", "30081", "55812", "142", "30081", "14461", "138", "30081", "40691", "137", "30081", "40692", "135", "", "00"], content_type: "UD2", device: "012", device_id: "0123456", device_timestamp: 1606665625, direction: "214", firm: "SG", gsm_signal: "100", latitude: "42.53534", latitude_mark: "N", lbs_stations: "6", lenght: "00BC", located: true, longitude: "14.14355", longitude_mark: "E", roll: "50", satellites: "08", speed: "0.0000", status: "00000000", steps: "0"}}

  """
  def parse(data) do
    data
    |> String.replace("[", "")
    |> String.replace("]", "")
    |> String.replace("\n", "")
    |> extract_headers!()
    |> extract_content!()
  end

  def response(data) do
    data
    |> get_type_module()
    |> call_reply()
  end

  defp extract_headers!(data) do
    case String.split(data, "*") do
      [firm, device_id, lenght, content] ->
        device =
          ~r/^[0-9]{3}/
          |> Regex.run(device_id)
          |> List.first()

        {:ok, struct(Elixir.Gateway.Data, [firm: firm, device: device, device_id: device_id, lenght: lenght, content: content])}
      _ -> {:error, "Unable to decode headers"}
    end
  end

  defp extract_content!({:ok, %{content: content} = headers}) do
    content
    |> String.split(",")
    |> Protocol.get_content_type(headers)
    |> get_type_module()
    |> call_decode()
  end

  defp extract_content!({:error, error}), do: {:error, error}

  defp get_type_module(%{content_type: type} = data) do
    {data, Protocol.get_content_decoder(type)}
  end

  defp call_decode({call, module}) do
    apply(module, :decode, [call])
  end

  defp call_reply({call, module}) do
    apply(module, :reply, [call])
  end
end
