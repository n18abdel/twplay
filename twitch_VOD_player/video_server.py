import os

from flask import Flask, Response, make_response, send_file
from flask_cors import CORS
from requests import get


def create_app(url):
    APP = Flask(__name__)
    CORS(APP)
    MEDIA_PATH = os.getcwd()

    @APP.route("/<vid_name>")
    def serve_local_file(vid_name):
        vid_path = os.path.join(MEDIA_PATH, vid_name)
        resp = make_response(send_file(vid_path, "video/mp4"))
        resp.headers["Content-Disposition"] = "inline"
        return resp

    @APP.route("/playlist.m3u8")
    def playlist():
        return reverse_proxy(url)

    @APP.route("/<part>.ts")
    def chunk(part):
        return reverse_proxy(url.replace("index-dvr.m3u8", f"{part}.ts"))

    def reverse_proxy(url):
        resp = get(url)
        excluded_headers = [
            "content-encoding",
            "content-length",
            "transfer-encoding",
            "connection",
        ]
        headers = [
            (name, value)
            for (name, value) in resp.raw.headers.items()
            if name.lower() not in excluded_headers
        ]
        return Response(resp.content, resp.status_code, headers)

    return APP


if __name__ == "__main__":
    url = "https://dgeft87wbj63p.cloudfront.net/f5fbeacf74402a5586ef_papesan_39890330184_1664540309/chunked/index-dvr.m3u8"
    APP = create_app(url)
    APP.run(host="192.168.0.36")
