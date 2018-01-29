defmodule EditorQueue.Queue do
  use GenServer
  require Logger

  defstruct [
    viewers: []
  ]

  def start_link(id) do
    GenServer.start_link(__MODULE__, id, name: ref(id))
  end

  def init(id) do
    {:ok, %__MODULE__{}}
  end

  def queue(id, viewer), do: GenServer.call(ref(id), {:queue, viewer})
  def pop(id, viewer), do: GenServer.call(ref(id), {:pop, viewer})
  def editor(id), do: GenServer.call(ref(id), {:editor})

  def handle_call({:queue, viewer}, _from, queue) do
    queue = %{queue | viewers: queue.viewers ++ [viewer]}
    {:reply, {:ok, queue}, queue}
  end

  def handle_call({:pop, viewer}, _from, queue) do
    queue = %{queue | viewers: queue.viewers |> Enum.filter(fn(x) -> x != viewer end)}
    {:reply, {:ok, queue}, queue}
  end

  def handle_call({:editor}, _from, queue) do
    {:reply, fetch_editor(queue.viewers), queue}
  end

  defp ref(id), do: {:global, {:edit_queue, id}}
  defp fetch_editor([]), do: nil
  defp fetch_editor([editor | _]), do: editor
end
