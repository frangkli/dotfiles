"""Run with python3 -m unittest discover -s <skill-directory>/scripts."""
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from urllib.error import HTTPError
from urllib.request import Request, urlopen


class PreviewTest(unittest.TestCase):
    def test_single_file_boundary(self):
        with tempfile.TemporaryDirectory() as directory:
            page = Path(directory) / "example ü.html"
            page.write_bytes(b"<h1>first</h1>")
            (Path(directory) / "private.txt").write_text("must not serve")
            server = subprocess.Popen(
                [sys.executable, str(Path(__file__).with_name("serve.py")), str(page)],
                stdout=subprocess.PIPE,
                text=True,
            )
            try:
                url = server.stdout.readline().strip()
                self.assertTrue(url.startswith("http://127.0.0.1:"))
                base = url.rsplit("/", 1)[0]
                for route in [url, base + "/"]:
                    with urlopen(route, timeout=5) as response:
                        self.assertEqual(response.read(), page.read_bytes())
                        self.assertEqual(response.headers["Cache-Control"], "no-store")
                    with urlopen(Request(route, method="HEAD"), timeout=5) as response:
                        self.assertEqual(response.read(), b"")
                        self.assertEqual(int(response.headers["Content-Length"]), page.stat().st_size)
                page.write_bytes(b"<h1>updated</h1>")
                with urlopen(url, timeout=5) as response:
                    self.assertEqual(response.read(), page.read_bytes())
                for route in ["/private.txt", "/../private.txt", "/%2e%2e/private.txt"]:
                    for method in ["GET", "HEAD"]:
                        with self.subTest(route=route, method=method):
                            with self.assertRaises(HTTPError) as caught:
                                urlopen(Request(base + route, method=method), timeout=5)
                            self.assertEqual(caught.exception.code, 404)
                            caught.exception.close()
            finally:
                server.terminate()
                server.wait(timeout=5)
                server.stdout.close()


if __name__ == "__main__":
    unittest.main()
