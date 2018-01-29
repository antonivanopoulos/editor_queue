defmodule EditorQueueWeb.PageController do
  use EditorQueueWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
