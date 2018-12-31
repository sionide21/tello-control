defmodule TelloControl.Video do
  use Supervisor
  alias __MODULE__.{Processor, Socket, PubSub}
  @socket Application.get_env(:tello_control, Socket, Socket)

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg)
  end

  @impl true
  def init(_arg) do
    children = [
      PubSub,
      @socket,
      Processor
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
