defmodule Twplay.CLI do
  def main(argv) do
    options =
      [
        local_file: [
          short: "-f",
          help: "a local file of the VOD"
        ],
        chat_file: [
          short: "-c",
          help: "a local chat file of the VOD"
        ],
        beginning: [
          short: "-b",
          help: """
          Time in seconds to crop beginning of chat.
          For example,
          if I wanted a 10 second stream but only wanted the last 7 seconds of it,
          I would use -b 3 to skip the first 3 seconds of it.
          """
        ],
        ending: [
          short: "-e",
          help: """
          Time in seconds to crop ending of chat.
          For example,
          if I wanted a 10 second stream but only wanted the first 4 seconds of it,
          I would use -e 4 remove the last 6 seconds of it.
          """
        ]
      ]
      |> Enum.map(fn {key, option} -> {key, Keyword.put(option, :long, "--#{key}")} end)

    parsed =
      Optimus.new!(
        name: Application.get_application(__MODULE__) |> to_string,
        description: "Play a Twitch VOD with the chat using MPV and a chat renderer",
        args: [
          url_or_user: [
            help: "a Twitch VOD url or a Twitch username",
            required: false
          ]
        ],
        options: options,
        flags: [
          cast: [
            long: "cast",
            help: "cast to shield tv"
          ]
        ]
      )
      |> Optimus.parse!(argv)

    parsed = put_in(parsed.args.url_or_user, parsed.args.url_or_user || "gun_won")

    vod_id =
      parsed.args.url_or_user
      |> Utils.parse_vod_id(parsed.options.local_file, parsed.options.chat_file)

    parsed.options.chat_file
    |> ChatRetriever.fetch(vod_id, parsed.options.beginning, parsed.options.ending)
    |> ChatRetriever.send()

    Player.Sup.start_child(parsed, vod_id)

    IO.puts("\n\nRemote access from using the following command (by filling <name>)")
    IO.puts("iex --remsh #{Node.self()} --sname <name>")

    IO.puts("\n\nPress q to exit")
    Utils.exit_loop()
  end
end
