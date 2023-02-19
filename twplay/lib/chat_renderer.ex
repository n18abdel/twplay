defmodule ChatRenderer do
  use GenServer, restart: :transient

  @impl true
  def init(_) do
    {:ok, nil, {:continue, :setup}}
  end

  @impl true
  def handle_continue(:setup, s) do
    :ok = RabbitMq.wait()

    Port.open({:spawn_executable, System.find_executable("open")}, [
      :exit_status,
      args: ["-a", "twitch_chat_render", "--wait-apps"]
    ])

    {:noreply, s}
  end

  @impl true
  def handle_info({_port, {:exit_status, _}}, s) do
    {:stop, :kill, s}
  end

  def start_link(init_arg), do: GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)

  def stop, do: GenServer.stop(__MODULE__)
end
