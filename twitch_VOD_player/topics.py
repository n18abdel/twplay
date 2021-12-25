from amqp import publish


def json(channel, chat):
    publish(channel, "json", chat)
    channel.close()


def seek(channel, pos):
    publish(channel, routing_key="sync.seek", body=str(pos))


def play(channel, pos):
    publish(channel, routing_key="sync.play", body=str(pos))


def pause(channel, pos):
    publish(channel, routing_key="sync.pause", body=str(pos))


def timer(channel, pos):
    publish(channel, routing_key="sync.timer", body=str(pos))


def chatExit(channel):
    publish(channel, routing_key="exit", body="")
