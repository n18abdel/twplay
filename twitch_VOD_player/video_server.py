import os

from flask import Flask, make_response, send_file

from controller import retrieve_local_ip

APP = Flask(__name__)
MEDIA_PATH = os.getcwd()


@APP.route("/<vid_name>")
def serve_video(vid_name):
    vid_path = os.path.join(MEDIA_PATH, vid_name)
    resp = make_response(send_file(vid_path, "video/mp4"))
    resp.headers["Content-Disposition"] = "inline"
    return resp


if __name__ == "__main__":
    APP.run(host=retrieve_local_ip())
