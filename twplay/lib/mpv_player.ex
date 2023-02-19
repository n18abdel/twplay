defmodule MpvPlayer do
  @enforce_keys [:main, :sup]
  defstruct [:main, :sup]
  alias MpvJsonIpc.Mpv
  require Mpv

  def start_child(module) do
    {:ok, sup} = DynamicSupervisor.start_child(module, Mpv.Sup)
    player = %MpvPlayer{main: Mpv.Sup.main(sup), sup: sup}
    :ok = MpvJsonIpc.ensure_loaded()

    Mpv.on_event player.main, "file-loaded" do
      player.main |> Mpv.Properties.Pause.set(true)
      player.main |> Mpv.Properties.Speed.set(1)
    end

    player
  end
end

defimpl Player, for: MpvPlayer do
  alias MpvJsonIpc.Mpv
  require Mpv

  def current_pos(%MpvPlayer{} = player) do
    player.main |> Mpv.Properties.Time_pos.get()
  end

  def play(%MpvPlayer{} = player, url) do
    options =
      %{
        "stream-lavf-o-append": "protocol_whitelist=file,http,https,tcp,tls,crypto,hls,applehttp",
        "merge-files": "yes"
      }
      |> Map.merge(
        if String.ends_with?(url, ".m3u8"),
          do: %{cache: "yes", "demuxer-max-bytes": "100MiB", "demuxer-max-back-bytes": "100MiB"},
          else: %{}
      )

    cmd = %{name: "loadfile", url: url, options: options}

    player.main |> Mpv.command(cmd)
  end

  def on_play(%MpvPlayer{} = player, func) do
    Mpv.property_observer player.main, "pause" do
      with false <- pause,
           {:ok, pos} <- player |> current_pos() do
        func.(pos)
      end
    end

    player
  end

  def on_pause(%MpvPlayer{} = player, func) do
    Mpv.property_observer player.main, "pause" do
      with true <- pause,
           {:ok, pos} <- player |> current_pos() do
        func.(pos)
      end
    end

    player
  end

  def on_seek(%MpvPlayer{} = player, func) do
    Mpv.on_event player.main, "seek" do
      with {:ok, pos} <- player |> current_pos() do
        func.(pos)
      end
    end

    player
  end

  def on_speed_change(%MpvPlayer{} = player, func) do
    Mpv.property_observer player.main, "speed" do
      func.(speed)
    end

    player
  end

  def on_end_of_file(%MpvPlayer{} = player, func) do
    Mpv.on_event player.main, "end-file" do
      if data[:reason] != "redirect" do
        func.()
        Task.start(fn -> :ok = player.sup |> Mpv.Sup.stop() end)
      end
    end

    player
  end
end
