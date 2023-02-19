defmodule ChatRetriever do
  use GenServer

  @impl true
  def init(_) do
    {:ok, nil}
  end

  @impl true
  def handle_call({:fetch, chat_file}, _, _) do
    chat = File.read!(chat_file)
    {:reply, chat, chat_file}
  end

  @impl true
  def handle_call({:fetch, vod_id, beginning, ending}, _, already_fetched?) do
    output_file =
      File.cwd!()
      |> Path.join("#{vod_id}.json")

    if !already_fetched? do
      args = [
        "chatdownload",
        "--id",
        vod_id |> to_string,
        "-o",
        output_file,
        "--chat-connections",
        "1"
      ]

      args = if beginning, do: args ++ ["-b", beginning], else: args
      args = if ending, do: args ++ ["-e", ending], else: args

      port =
        Port.open({:spawn_executable, System.find_executable("TwitchDownloaderCLI")}, [
          :exit_status,
          args: args
        ])

      0 = print_stdout(port)
    end

    chat = File.read!(output_file)
    {:reply, chat, output_file}
  end

  @impl true
  def handle_call(:fetch, _, chat_file) do
    chat = File.read!(chat_file)
    {:reply, chat, chat_file}
  end

  def start_link(init_arg), do: GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)

  def fetch(chat_file) when is_binary(chat_file),
    do: GenServer.call(__MODULE__, {:fetch, chat_file})

  def fetch(vod_id, beginning \\ nil, ending \\ nil) when is_integer(vod_id),
    do: GenServer.call(__MODULE__, {:fetch, vod_id, beginning, ending}, :infinity)

  def fetch, do: GenServer.call(__MODULE__, :fetch)

  def fetch(chat_file, vod_id, beginning, ending) do
    if chat_file do
      fetch(chat_file)
    else
      fetch(vod_id, beginning, ending)
    end
  end

  def send(chat) do
    :ok = RabbitMq.wait()
    :timer.seconds(1) |> Process.sleep()
    chat |> RabbitMq.json()
  end

  defp print_stdout(port) do
    receive do
      {^port, {:data, value}} ->
        IO.write("\r#{value}")
        print_stdout(port)

      {^port, {:exit_status, value}} ->
        value
    end
  end
end
