defmodule TelloControl.Video.FakeSocket do
  defstruct [:source, :buffer]
  alias TelloControl.Video.Processor
  use GenServer
  require Logger

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init([]) do
    filename = Application.get_env(:tello_control, __MODULE__)[:capture_file]
    {:ok, file} = File.open(filename, [:read, :binary, :raw])
    file = IO.binread(file, :all)
    :timer.send_interval(30, :read_nal)
    Logger.info("Replaying video stream from #{filename}")

    {:ok, %__MODULE__{source: file, buffer: file}}
  end

  @impl true
  def handle_info(:read_nal, %{buffer: ""} = state) do
    handle_info(:read_nal, %{state | buffer: state.source})
  end

  @impl true
  def handle_info(:read_nal, state) do
    {nal, buffer} = read_nal(state.buffer)
    type = nal_type(nal)
    Processor.send_nal(type, nal)

    {:noreply, %{state | buffer: buffer}}
  end

  def nal_type(<<0, 0, 0, 1, 0::size(1), _nri::size(2), type::size(5)>> <> _), do: type
  def nal_type(<<0, 0, 1, 0::size(1), _nri::size(2), type::size(5)>> <> _), do: type

  def read_nal(<<0, 0, 0, 1>> <> buffer) do
    {nal, buffer} = read_nal(buffer, "")
    {<<0, 0, 0, 1>> <> nal, buffer}
  end

  def read_nal(<<0, 0, 1>> <> buffer) do
    {nal, buffer} = read_nal(buffer, "")
    {<<0, 0, 1>> <> nal, buffer}
  end

  def read_nal(<<0, 0, 0, 1>> <> _ = buffer, nal) do
    {nal, buffer}
  end

  def read_nal(<<0, 0, 1>> <> _ = buffer, nal) do
    {nal, buffer}
  end

  def read_nal("", nal) do
    {nal, ""}
  end

  def read_nal(<<byte::binary-size(1)>> <> buffer, nal) do
    read_nal(buffer, nal <> byte)
  end
end
