defmodule EditorQueue.QueueSupervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(EditorQueue.Queue, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

   def create_queue(id) do
     Supervisor.start_child(__MODULE__, [id])
   end
 end
