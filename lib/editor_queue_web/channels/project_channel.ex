defmodule EditorQueueWeb.ProjectChannel do
  use EditorQueueWeb, :channel

  alias EditorQueue.{QueueSupervisor, Queue}
  alias EditorQueueWeb.{Endpoint}

  def join("project:" <> project_id, _params, socket) do
    send(self(), :after_join)
    {:ok, assign(socket, :project_id, project_id)}
  end

  def handle_info(:after_join, socket) do
    subscribe_editor(socket)
    queue_viewer(socket.assigns.project_id, socket.assigns.user_id)

    editor = Queue.editor(socket.assigns.project_id)
    if editor == socket.assigns.user_id do
      notify_editor(socket.assigns.project_id, editor)
    end

    {:noreply, socket}
  end

  def terminate(_payload, socket) do
    old_editor = Queue.editor(socket.assigns.project_id)
    Queue.pop(socket.assigns.project_id, socket.assigns.user_id)
    new_editor = Queue.editor(socket.assigns.project_id)

    if old_editor != new_editor do
      notify_editor(socket.assigns.project_id, new_editor)
    end

    socket
  end

  defp subscribe_editor(socket) do
    Phoenix.PubSub.subscribe(
      socket.pubsub_server,
      editor_topic(socket.assigns.project_id, socket.assigns.user_id),
      fastlane: {socket.transport_pid, socket.serializer, []}
    )
  end

  defp editor_topic(project_id, user_id), do: "project:#{project_id}:editor:#{user_id}"
  defp queue_viewer(project_id, user_id) do
    QueueSupervisor.create_queue(project_id)
    Queue.queue(project_id, user_id)
  end

  defp notify_editor(project_id, user_id) do
    Endpoint.broadcast!(editor_topic(project_id, user_id), "editing_enabled", %{})
  end
end
