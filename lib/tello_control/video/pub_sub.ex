defmodule TelloControl.Video.PubSub do
  def child_spec([]) do
    Registry.child_spec(
      keys: :duplicate,
      partitions: System.schedulers_online(),
      name: __MODULE__
    )
  end

  def subscribe() do
    Registry.register(__MODULE__, __MODULE__, [])
  end

  def publish_frame(frame) do
    Registry.dispatch(__MODULE__, __MODULE__, fn entries ->
      for {pid, _} <- entries, do: send(pid, {:video_frame, frame})
    end)
  end
end
