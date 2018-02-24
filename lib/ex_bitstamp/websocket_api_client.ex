defmodule ExBitstamp.WebsocketApiClient do
  use WebSockex

  alias ExBitstamp.Frame

  @ex_bitstamp_version "0.1.1"
  @process_name :ex_bitstamp_websocket_client
  @pusher_client_name "elixir-ex_bitstamp"
  @pusher_key "de504dc5763aeef9ff52"
  @pusher_protocol_version 5

  def start_link() do
    WebSockex.start_link("ws://ws-mt1.pusher.com:80/app/#{@pusher_key}?client=#{@pusher_client_name}&version=#{@ex_bitstamp_version}&protocol=#{@pusher_protocol_version}", __MODULE__, %{}, name: @process_name)
  end

  def register(channel, fun) when is_function(fun, 1) do
    client =
      case Process.whereis(@process_name) do
        nil ->
          {:ok, pid} = start_link()
          pid

        pid -> pid
      end
    send(client, {:register, channel, fun})
  end

  def handle_frame({:text, json}, state) do
    frame =
      json
      |> Poison.decode!()
      |> Map.update("data", %{}, &Poison.decode!(&1))
      |> struct_frame()

    if state[frame.channel] do
      Enum.each(state[frame.channel], fn fun -> fun.(frame) end)
    end
    {:ok, state}
  end

  defp struct_frame(frame) when is_map(frame) do
    %Frame{
      channel: frame["channel"],
      data: frame["data"],
      event: frame["event"]
    }
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts "Sending #{type} frame with payload: #{msg}"
    {:reply, frame, state}
  end

  def handle_info({:register, channel, fun}, state) do
    case Map.get(state, channel) do
      nil ->
        WebSockex.cast(
          self(),
          {:send, {:text, Poison.encode!(%{
            "event" => "pusher:subscribe",
            "data" => %{"channel" => channel}
          })}}
        )
        {:ok, Map.put(state, channel, [fun])}

      registrar ->
        {:ok, Map.put(state, channel, registrar ++ [fun])}
    end
  end
end