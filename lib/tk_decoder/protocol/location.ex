defmodule TkDecoder.Protocol.Location do
  @moduledoc """
  Location packets contains a lot of GPS informations

  Those packets doesn't requires a response to keep the socket alive.
  """
  alias TkDecoder.Protocol

  @doc ~S"""
  Parse device location data and store it into Protocol struct

  ## Examples

      iex> TkDecoder.Protocol.Location.decode(%Protocol{content: ["291120","160025","A","45.14321","N","13.32313","E","0.0000","214","1","08","100","70","0","50","00000000","6","1","222","10","30081","40593","160","30081","40591","147","30081","55812","142","30081","14461","138","30081","40691","137","30081","40692","135","","00"]})
      {:noreply, %TkDecoder.Protocol{acc: nil, altitude: "1", battery: "70", content: ["1", "222", "10", "30081", "40593", "160", "30081", "40591", "147", "30081", "55812", "142", "30081", "14461", "138", "30081", "40691", "137", "30081", "40692", "135", "", "00"], content_type: nil, device: nil, device_id: nil, device_timestamp: 1606665625, direction: "214", firm: nil, gsm_signal: "100", latitude: "45.14321", latitude_mark: "N", lbs_stations: "6", lenght: nil, located: true, longitude: "13.32313", longitude_mark: "E", roll: "50", satellites: "08", speed: "0.0000", status: "00000000", steps: "0"}}

  """
  def decode(data) do
    data
    |> get_date_time()
    |> get_located()
    |> get_latitude()
    |> get_longitude()
    |> get_speed()
    |> get_direction()
    |> get_altitude()
    |> get_satellites()
    |> get_gsm_signal()
    |> get_battery()
    |> get_steps()
    |> get_roll()
    |> get_status()
    |> get_lbs_stations()
    |> reply()
  end

  defp reply(data), do: {:noreply, data}

  defp get_date_time(%Protocol{content: [date, time | content]} = data) do
    [_, day, month, year, hour, minute, second] =
      ~r/([0-9]{2})+([0-9]{2})+([0-9]{2}):([0-9]{2})+([0-9]{2})+([0-9]{2})/
      |> Regex.run("#{date}:#{time}")

    dt = %DateTime{
      year: String.to_integer("20#{year}"),
      month: String.to_integer(month),
      day: String.to_integer(day),
      zone_abbr: "UTC",
      hour: String.to_integer(hour),
      minute: String.to_integer(minute),
      second: String.to_integer(second),
      microsecond: {0, 0},
      utc_offset: 0,
      std_offset: 0,
      time_zone: "Etc/UTC"
    }

    %{data | device_timestamp: DateTime.to_unix(dt), content: content}
  end

  defp get_located(%Protocol{content: ["A" | content]} = data),
    do: %{data | located: true, content: content}

  defp get_located(%Protocol{content: ["V" | content]} = data),
    do: %{data | located: false, content: content}

  defp get_latitude(%Protocol{content: [latitude, mark | content]} = data),
    do: %{data | latitude: latitude, latitude_mark: mark, content: content}

  defp get_longitude(%Protocol{content: [longitude, mark | content]} = data),
    do: %{data | longitude: longitude, longitude_mark: mark, content: content}

  defp get_speed(%Protocol{content: [speed | content]} = data),
    do: %{data | speed: speed, content: content}

  defp get_direction(%Protocol{content: [direction | content]} = data),
    do: %{data | direction: direction, content: content}

  defp get_altitude(%Protocol{content: [altitude | content]} = data),
    do: %{data | altitude: altitude, content: content}

  defp get_satellites(%Protocol{content: [satellites | content]} = data),
    do: %{data | satellites: satellites, content: content}

  defp get_gsm_signal(%Protocol{content: [gsm_signal | content]} = data),
    do: %{data | gsm_signal: gsm_signal, content: content}

  defp get_battery(%Protocol{content: [battery | content]} = data),
    do: %{data | battery: battery, content: content}

  defp get_steps(%Protocol{content: [steps | content]} = data),
    do: %{data | steps: steps, content: content}

  defp get_roll(%Protocol{content: [roll | content]} = data),
    do: %{data | roll: roll, content: content}

  # WIP v
  defp get_status(%Protocol{content: [status | content]} = data),
    do: %{data | status: status, content: content}

  defp get_lbs_stations(%Protocol{content: [lbs_stations | content]} = data),
    do: %{data | lbs_stations: lbs_stations, content: content}

  # WIP: Connect LBS station, MCC Country code, MNC Network Number, Connecting the LBS Location area code, Connect LBS code, The strength of LBS signal, Nearing LBS station 1’s location area code, ...
end
