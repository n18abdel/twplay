defmodule Twitch do
  @domains [
    "https://vod-secure.twitch.tv/",
    "https://vod-metro.twitch.tv/",
    "https://vod-pop-secure.twitch.tv/",
    "https://d2e2de1etea730.cloudfront.net/",
    "https://dqrpb9wgowsf5.cloudfront.net/",
    "https://ds0h3roq6wcgc.cloudfront.net/",
    "https://d2nvs31859zcd8.cloudfront.net/",
    "https://d2aba1wr3818hz.cloudfront.net/",
    "https://d3c27h4odz752x.cloudfront.net/",
    "https://dgeft87wbj63p.cloudfront.net/",
    "https://d1m7jfoe9zdc1j.cloudfront.net/",
    "https://d3vd9lfkzbru3h.cloudfront.net/",
    "https://d2vjef5jvl6bfs.cloudfront.net/",
    "https://d1ymi26ma8va5x.cloudfront.net/",
    "https://d1mhjrowxxagfy.cloudfront.net/",
    "https://ddacn6pr5v0tl.cloudfront.net/",
    "https://d3aqoihi2n8ty8.cloudfront.net/"
  ]

  def url(tracker_url) when is_binary(tracker_url) do
    [streamer, broadcast_id] =
      Regex.run(~r"twitchtracker.com/(.*)/streams/(\d+)", tracker_url, capture: :all_but_first)

    Utils.launch(&flaresolverr_running?/0, &flaresolverr_cmd/0)

    {:ok, {{_, 200, _}, _, body}} =
      :httpc.request(
        :post,
        {'http://localhost:8191/v1', [], 'application/json',
         %{
           cmd: "request.get",
           url: tracker_url,
           maxTimeout: 60000
         }
         |> Jason.encode!()},
        http_request_opts(),
        []
      )

    {:ok, ts} =
      body
      |> Jason.decode!(keys: :atoms)
      |> get_in([:solution, :response])
      |> timestamp()

    base_url = [streamer, "_", broadcast_id, "_", ts |> to_string]

    hashed_base_url =
      :crypto.hash(:sha, base_url)
      |> Base.encode16()
      |> String.slice(0, 20)
      |> String.downcase()

    @domains
    |> Stream.map(&[&1, hashed_base_url, "_", base_url, "/chunked/index-dvr.m3u8"])
    |> Enum.find(
      &match?({:ok, {{_, 200, _}, _, _}}, :httpc.request(:get, {&1, []}, http_request_opts(), []))
    )
    |> IO.iodata_to_binary()
    |> unmute()
  end

  def url(vod_id) do
    {:ok, {{_, 200, _}, _, body}} =
      :httpc.request(
        :get,
        {"https://api.twitch.tv/kraken/videos/#{vod_id}",
         [
           {'User-Agent', 'Mozilla/5.0'},
           {'Accept', 'application/vnd.twitchtv.v5+json'},
           {'Client-ID', 'kimne78kx3ncx6brgo4mv6wki5h1ko'}
         ]},
        http_request_opts(),
        []
      )

    body
    |> Jason.decode!(keys: :atoms)
    |> Map.get(:seek_previews_url)
    |> String.replace(~r"storyboards.*", "chunked/index-dvr.m3u8")
    |> unmute()
  end

  defp timestamp(body) do
    with [date] <-
           Regex.run(~r"stream on (\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})", body,
             capture: :all_but_first
           ),
         {:ok, naive_dt} <- NaiveDateTime.from_iso8601(date),
         {:ok, dt} <- DateTime.from_naive(naive_dt, "Etc/UTC") do
      {:ok, DateTime.to_unix(dt)}
    end
  end

  defp http_request_opts do
    unless res = :persistent_term.get(:http_request_opts, nil) do
      res = [
        ssl: [
          verify: :verify_peer,
          cacerts: :public_key.cacerts_get(),
          customize_hostname_check: [
            match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
          ]
        ]
      ]

      :ok =
        :persistent_term.put(
          :http_request_opts,
          res
        )

      res
    else
      res
    end
  end

  defp flaresolverr_running? do
    case :httpc.request("http://localhost:8191") do
      {:ok, {{_, 200, _}, _, _}} -> true
      _ -> false
    end
  end

  defp flaresolverr_cmd(),
    do:
      System.cmd("docker", [
        "run",
        "-d",
        "--name=flaresolverr",
        "-p",
        "8191:8191",
        "-e",
        "LOG_LEVEL=info",
        "--restart",
        "unless-stopped",
        "ghcr.io/flaresolverr/flaresolverr:latest"
      ])

  defp muted?(url) do
    {:ok, {{_, 200, _}, _, body}} = :httpc.request(:get, {url, []}, http_request_opts(), [])
    body |> to_string() |> String.contains?("unmuted")
  end

  defp id(url), do: url |> String.split("/") |> Enum.at(3)

  defp do_unmute(line, base_url) do
    cond do
      String.contains?(line, "unmuted") -> base_url <> String.replace(line, "unmuted", "muted")
      String.ends_with?(line, ".ts") -> base_url <> line
      true -> line
    end
  end

  defp unmute(url) do
    if muted?(url) do
      filepath =
        System.tmp_dir!()
        |> Path.join(__MODULE__ |> Application.get_application() |> to_string)
        |> Path.join([id(url), ".m3u8"])

      filepath |> Path.dirname() |> File.mkdir_p!()

      base_url = url |> String.replace("index-dvr.m3u8", "")

      {:ok, {{_, 200, _}, _, body}} = :httpc.request(:get, {url, []}, http_request_opts(), [])

      body
      |> to_string()
      |> String.splitter(:binary.compile_pattern(["\r", "\n", "\r\n"]))
      |> Stream.map(&do_unmute(&1, base_url))
      |> Stream.map(&(&1 <> "\n"))
      |> Stream.into(File.stream!(filepath))
      |> Stream.run()

      filepath
    else
      url
    end
  end
end
