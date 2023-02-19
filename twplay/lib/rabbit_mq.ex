defmodule RabbitMq do
  use GenServer

  @impl true
  def init(_) do
    {:ok, nil, {:continue, :setup}}
  end

  @impl true
  def handle_continue(:setup, _) do
    Utils.launch(&docker_running?/0, &docker_cmd/0)
    Utils.launch(&rabbitmq_running?/0, &rabbitmq_cmd/0)
    {:ok, connection} = AMQP.Connection.open()
    Process.link(connection.pid)
    {:ok, channel} = AMQP.Channel.open(connection)
    AMQP.Exchange.declare(channel, "topic_chat", :topic)
    {:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel, "", exclusive: true)
    AMQP.Queue.bind(channel, queue_name, "topic_chat", routing_key: "reconnect")
    AMQP.Basic.consume(channel, queue_name, nil, no_ack: true)
    {:noreply, channel}
  end

  @impl true
  def handle_call({topic, value}, _, channel) do
    reply = AMQP.Basic.publish(channel, "topic_chat", topic |> to_string, value |> to_string)
    {:reply, reply, channel}
  end

  @impl true
  def handle_call(:wait, _, channel) do
    {:reply, :ok, channel}
  end

  @impl true
  def handle_info({:basic_deliver, _payload, _meta}, channel) do
    AMQP.Basic.publish(channel, "topic_chat", "json", ChatRetriever.fetch())
    {:noreply, channel}
  end

  for msg <- [:basic_consume_ok, :basic_cancel, :basic_cancel_ok] do
    @impl true
    def handle_info({unquote(msg), _}, channel) do
      {:noreply, channel}
    end
  end

  def start_link(init_arg), do: GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)

  def json(chat), do: GenServer.call(__MODULE__, {:json, chat})
  def chat_exit(), do: GenServer.call(__MODULE__, {:exit, ""})

  for sync <- [:seek, :play, :pause, :timer, :speed] do
    def unquote(sync)(value), do: GenServer.call(__MODULE__, {"sync.#{unquote(sync)}", value})
  end

  def wait, do: GenServer.call(__MODULE__, :wait, :infinity)

  defp docker_running? do
    {_stdout, exit_status} = System.cmd("docker", ["info"], stderr_to_stdout: true)
    exit_status == 0
  end

  defp rabbitmq_running? do
    case :httpc.request("http://localhost:15672") do
      {:ok, {{_, 200, _}, _, _}} -> true
      _ -> false
    end
  end

  defp docker_cmd(), do: System.cmd("open", ["-a", "Docker"], stderr_to_stdout: true)

  defp rabbitmq_cmd(),
    do:
      System.cmd("docker", [
        "run",
        "-d",
        "--rm",
        "-p",
        "15672:15672",
        "-p",
        "5672:5672",
        "rabbitmq:3-management"
      ])
end
