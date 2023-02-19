defmodule Utils do
  @sleep :timer.seconds(5)
  def parse_vod_id(url_or_user, local_file, chat_file) do
    cond do
      local_file && chat_file ->
        nil

      res = Regex.run(~r"twitch.tv/videos/(\d+)", url_or_user, capture: :all_but_first) ->
        res |> List.first() |> String.to_integer()

      Regex.run(~r"twitchtracker.com/.*/streams/(\d+)", url_or_user) ->
        nil

      user_id = retrieve_user_id(url_or_user) ->
        retrieve_last_vod_id(user_id)

      true ->
        IO.puts("""
        Couldn't parse VOD id
        The URL should have the following form:
        twitch.tv/videos/<vod_id>
        OR
        http://twitch.tv/videos/<vod_id>
        OR
        https://twitch.tv/videos/<vod_id>
        """)

        System.halt(1)
    end
  end

  def retrieve_user_id(username) do
    {out, 0} = System.cmd("twitch", ["api", "get", "users", "-q", "login=#{username}"])

    case out |> Jason.decode!(keys: :atoms) |> Map.get(:data) do
      [%{id: user_id}] -> user_id
      _ -> nil
    end
  end

  def retrieve_last_vod_id(user_id) do
    {out, 0} =
      System.cmd("twitch", [
        "api",
        "get",
        "videos",
        "-q",
        "user_id=#{user_id}",
        "-q",
        "first=1",
        "-q",
        "type=archive"
      ])

    out
    |> Jason.decode!(keys: :atoms)
    |> Map.get(:data)
    |> List.first()
    |> Map.get(:id)
    |> String.to_integer()
  end

  def timer_loop(player, func) do
    with {:ok, pos} <- player |> Player.current_pos() do
      func.(pos)
    end
  end

  def setup_timer_loop(player, func) do
    :timer.apply_interval(:timer.minutes(1), __MODULE__, :timer_loop, [player, func])
    player
  end

  def get_media(local_file, url_or_user, vod_id, _cast) do
    cond do
      local_file -> local_file
      vod_id -> Twitch.url(vod_id)
      url_or_user -> Twitch.url(url_or_user)
    end
  end

  def exit_handler do
    ChatRenderer.stop()
    RabbitMq.chat_exit()
    System.halt()
  end

  def exit_loop() do
    case IO.read(1) do
      "q" -> exit_handler()
      _ -> exit_loop()
    end
  end

  defp backoff(attempt) do
    0..(2 ** attempt) |> Enum.random() |> Kernel.*(@sleep) |> Process.sleep()
  end

  def launch(running?, cmd, attempt \\ 0) do
    if !apply(running?, []) do
      apply(cmd, [])
      backoff(attempt)
      launch(running?, cmd, attempt + 1)
    end
  end
end
