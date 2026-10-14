"""Build the current 17-slide HTML presentation from the supplied concise framework."""
from pathlib import Path
import os
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]

def build():
    node = os.environ.get("NODE_BINARY") or shutil.which("node")
    if not node:
        raise RuntimeError("Node.js is required. Set NODE_BINARY to its executable path.")
    subprocess.run([node, str(ROOT / "tools/build_presentation.cjs")], check=True)

if __name__ == "__main__":
    build()
