defmodule HelloPhoenix.CheckMxChannel do
  use Phoenix.Channel

  def join(_channel_name, _message, socket) do
    {:ok, socket}
  end

  def handle_in(_msg, %{"body" => body}, socket) do
    broadcast! socket, "generic_msg", %{body: body}
    {:noreply, socket}
  end

  def handle_out(_msg, payload, socket) do
    push socket, "generic_msg", payload
    {:noreply, socket}
  end
end
