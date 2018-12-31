defmodule TelloControl.Video.Processor do
  defstruct [:sps, :pps]
  alias TelloControl.Video.PubSub
  use GenServer
  require Logger

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def send_nal(type, nal) do
    GenServer.cast(__MODULE__, {:nal, type, nal})
  end

  @impl true
  def init([]) do
    {:ok, %__MODULE__{}}
  end

  @impl true
  def handle_cast({:nal, 7, nal}, state) do
    # Logger.debug("Got SPS: #{inspect(nal)}")
    {:noreply, %{state | sps: nal}}
  end

  def handle_cast({:nal, 8, nal}, state) do
    # Logger.debug("Got PPS: #{inspect(nal)}")
    {:noreply, %{state | pps: nal}}
  end

  def handle_cast({:nal, _type, nal}, %{sps: sps, pps: pps} = state)
      when is_binary(sps) and is_binary(pps) do
    # Logger.debug("Got NAL type=#{type} size=#{byte_size(nal)}")
    PubSub.publish_frame([sps, pps, nal])
    {:noreply, state}
  end

  def handle_cast({:nal, _type, _nal}, state) do
    # Logger.debug("Dropping NAL type=#{type} size=#{byte_size(nal)}")
    {:noreply, state}
  end
end
