defmodule ElixirService.CheckMxChannel do
  use Phoenix.Channel

  require Logger

  def join(channel_name, message, socket) do
    Logger.info("join(#{channel_name},#{inspect(message)},...)")
    {:ok, socket}
  end

  def handle_in("check-mx", %{"email" => email}, socket) do
    response = ElixirService.MailCheck.check(email)

    Task.start  (fn ->
      Logger.info("check-mx, %{ \"email\" => #{email}},...) => #{inspect(response)}")
      push socket, "check-mx", response
    end)

    {:noreply, socket}
  end

  def handle_in(msg, payload, socket) do
    Logger.info("handle_in(#{msg}, #{inspect(payload)},...)")
    {:noreply, socket}
  end

  def handle_out(msg, payload, socket) do
    Logger.info("handle_out(#{msg},#{payload},...)")
    {:noreply, socket}
  end
end
