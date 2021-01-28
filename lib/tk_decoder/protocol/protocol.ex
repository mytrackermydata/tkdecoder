defmodule TkDecoder.Protocol do
  alias TkDecoder.Protocol.{Link, Custom, Location}

  def get_content_type(["LK" | content], headers),
    do: %{headers | content_type: "LK", content: content}

  def get_content_type(["UD" | content], headers),
    do: %{headers | content_type: "UD", content: content}

  def get_content_type(["UD2" | content], headers),
    do: %{headers | content_type: "UD2", content: content}

  def get_content_type(["AL" | content], headers),
    do: %{headers | content_type: "AL", content: content}

  def get_content_type(["WAD" | content], headers),
    do: %{headers | content_type: "WAD", content: content}

  def get_content_type(["WG" | content], headers),
    do: %{headers | content_type: "WG", content: content}

  def get_content_type([_ | content], headers),
    do: %{headers | content_type: "Unknown", content: content}

  def get_content_decoder("LK"), do: Link
  def get_content_decoder("UD"), do: Location
  def get_content_decoder("UD2"), do: Location
  def get_content_decoder("AL"), do: Custom
  def get_content_decoder("WAD"), do: Custom
  def get_content_decoder("WG"), do: Custom
  def get_content_decoder(_), do: Custom


  def make_response(
        %{firm: firm, device_id: device_id},
        additional_data
      ) do
    "[#{firm}*#{device_id}*#{integer_to_hexadecimal(additional_data)}*#{additional_data}]"
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
