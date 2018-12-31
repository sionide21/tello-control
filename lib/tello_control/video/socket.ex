defmodule TelloControl.Video.Socket do
  defstruct [:socket, :header, :nal]
  alias TelloControl.Video.Processor
  use GenServer
  require Logger

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init([]) do
    {:ok, socket} = :gen_udp.open(11111, active: :once, mode: :binary, reuseaddr: true)
    Logger.info("Listening for video stream on port 11111")

    {:ok, %__MODULE__{socket: socket, nal: []}}
  end

  @impl true
  def handle_info({:udp, _socket, _host, _port, packet}, state) do
    :inet.setopts(state.socket, active: :once)
    state = handle_packet(state, packet)
    {:noreply, state}
  end

  def process_nal(%{header: nil} = state) do
    state
  end

  def process_nal(state) do
    nal = IO.iodata_to_binary(state.nal)
    type = nal_type(state.header)
    Processor.send_nal(type, nal)

    %{state | nal: [], header: nil}
  end

  def nal_type(<<0::size(1), _nri::size(2), type::size(5)>>), do: type

  def handle_packet(state, <<0, 0, 1, header::binary-size(1)>> <> _ = new_nal) do
    handle_new_nal(state, header, new_nal)
  end

  def handle_packet(state, <<0, 0, 0, 1, header::binary-size(1)>> <> _ = new_nal) do
    handle_new_nal(state, header, new_nal)
  end

  def handle_packet(state, remainder) do
    append_packet(state, remainder)
  end

  def handle_new_nal(state, header, packet) do
    state
    |> process_nal()
    |> set_header(header)
    |> append_packet(packet)
  end

  def set_header(state, header) do
    %{state | header: header}
  end

  def append_packet(state, packet) do
    %{state | nal: [state.nal | packet]}
  end
end
