defmodule TkDecoder.Rabbit.Publish do
  @moduledoc nil

  alias Amqpx.Gen.Producer

  def send_data(payload) do
    Producer.publish("gps", "", payload)
  end
end
