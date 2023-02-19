defprotocol Player do
  def current_pos(player)
  def play(player, url)
  def on_play(player, func)
  def on_pause(player, func)
  def on_seek(player, func)
  def on_speed_change(player, func)
  def on_end_of_file(player, func)
end

defmodule Player.Sup do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(parsed, vod_id) do
    player =
      if false do
        # TODO Cast implementation
      else
        MpvPlayer.start_child(__MODULE__)
      end

    player
    |> Utils.setup_timer_loop(&RabbitMq.timer/1)
    |> Player.on_seek(&RabbitMq.seek/1)
    |> Player.on_play(&RabbitMq.play/1)
    |> Player.on_pause(&RabbitMq.pause/1)
    |> Player.on_speed_change(&RabbitMq.speed/1)
    |> Player.on_end_of_file(&Utils.exit_handler/0)
    |> Player.play(
      Utils.get_media(
        parsed.options.local_file,
        parsed.args.url_or_user,
        vod_id,
        parsed.flags.cast
      )
    )
  end
end
