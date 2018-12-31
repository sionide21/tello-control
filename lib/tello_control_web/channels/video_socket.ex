defmodule TelloControlWeb.VideoSocket do
  require Logger
  @behaviour Phoenix.Socket.Transport

  def child_spec(_opts) do
    # We won't spawn any process, so let's return a dummy task
    %{id: Task, start: {Task, :start_link, [fn -> :ok end]}, restart: :transient}
  end

  def connect(map) do
    Logger.debug("New VideoSocket connection: #{inspect(map)}")
    {:ok, []}
  end

  def init([]) do
    Logger.debug("Subscribing to video feed")
    TelloControl.Video.PubSub.subscribe()
    {:ok, []}
  end

  def handle_in({"heartbeat", _opts}, state) do
    {:ok, state}
  end

  def handle_in(msg, state) do
    Logger.warn("Unexpected client message: #{inspect(msg)}")
    {:ok, state}
  end

  def handle_info({:video_frame, frame}, state) do
    {:push, {:binary, frame}, state}
  end

  def terminate(reason, _state) do
    Logger.debug("Closing VideoSocket connection: #{inspect(reason)}")
    :ok
  end
end
