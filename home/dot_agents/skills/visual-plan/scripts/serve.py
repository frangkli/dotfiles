#!/usr/bin/env python3
"""Preview one standalone HTML file on loopback, without serving its directory."""
import argparse
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import quote, urlsplit


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("file", type=Path)
    parser.add_argument("--port", type=int, default=0)
    args = parser.parse_args()
    path = args.file.expanduser().resolve()
    if not path.is_file() or path.suffix.lower() not in {".html", ".htm"}:
        parser.error("file must be an existing HTML file")
    if not 0 <= args.port <= 65535:
        parser.error("port must be between 0 and 65535")
    route = "/" + quote(path.name)

    class Handler(BaseHTTPRequestHandler):
        def do_GET(self):
            self.respond(send_body=True)

        def do_HEAD(self):
            self.respond(send_body=False)

        def respond(self, send_body):
            if urlsplit(self.path).path not in {"/", route}:
                self.send_error(404)
                return
            try:
                content = path.read_bytes()
            except OSError:
                self.send_error(404)
                return
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(content)))
            self.send_header("Cache-Control", "no-store")
            self.send_header("X-Content-Type-Options", "nosniff")
            self.end_headers()
            if send_body:
                self.wfile.write(content)

        def log_message(self, *_):
            pass

    with ThreadingHTTPServer(("127.0.0.1", args.port), Handler) as server:
        print(f"http://127.0.0.1:{server.server_port}{route}", flush=True)
        try:
            server.serve_forever()
        except KeyboardInterrupt:
            pass


if __name__ == "__main__":
    main()
