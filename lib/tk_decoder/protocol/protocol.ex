defmodule TkDecoder.Protocol do
  @derive Jason.Encoder
  alias TkDecoder.Protocol.{Link, Custom, Location}

  defstruct [
    :firm,
    :device,
    :device_id,
    :lenght,
    :content,
    :content_type,
    :steps,
    :battery,
    :acc,
    :device_timestamp,
    :located,
    :latitude,
    :latitude_mark,
    :longitude,
    :longitude_mark,
    :speed,
    :direction,
    :altitude,
    :satellites,
    :gsm_signal,
    :roll,
    :status,
    :lbs_stations
  ]

  def get_content_type(["LK" | content], headers),
    do: {%{headers | content_type: "LK", content: content}, Link}

  def get_content_type(["UD" | content], headers),
    do: {%{headers | content_type: "UD", content: content}, Location}

  def get_content_type(["UD2" | content], headers),
    do: {%{headers | content_type: "UD2", content: content}, Location}

  def get_content_type(["AL" | content], headers),
    do: {%{headers | content_type: "AL", content: content}, Custom}

  def get_content_type(["WAD" | content], headers),
    do: {%{headers | content_type: "WAD", content: content}, Custom}

  def get_content_type(["WG" | content], headers),
    do: {%{headers | content_type: "WG", content: content}, Custom}

  def get_content_type([_ | content], headers),
    do: {%{headers | content_type: "Unknown", content: content}, Custom}

  def make_response(
        %{firm: firm, device_id: device_id},
        additional_data
      ) do
    "#{firm}*#{device_id}*#{integer_to_hexadecimal(additional_data)}*#{additional_data}"
  end

  defp integer_to_hexadecimal(value) do
    value
    |> String.length()
    |> Integer.to_string(16)
    |> add_digits()
  end

  defp add_digits(string) when byte_size(string) == 1, do: "000#{string}"
  defp add_digits(string) when byte_size(string) == 2, do: "00#{string}"
  defp add_digits(string) when byte_size(string) == 3, do: "0#{string}"
end
