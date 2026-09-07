#!/usr/bin/env python3
"""Insert the docs/ gallery into README.md, once the images actually exist."""
import os, sys

repo = sys.argv[1]
readme = os.path.join(repo, "README.md")
text = open(readme).read()
if "<!-- gallery -->" in text:
    print("  README gallery already present")
    sys.exit(0)

have = lambda n: os.path.exists(os.path.join(repo, "docs", n))
rows = []
if have("bar.png"):
    rows.append("![The bar](docs/bar.png)\n")
if have("demo.gif"):
    rows.append("Workspace switching, split flipping and grouping:\n\n![demo](docs/demo.gif)\n")

tiles = [("tiling-three-columns.png", "Three columns"),
         ("tiling-vertical-split.png", "After OPT+J"),
         ("tiling-mixed-split.png", "After OPT+CMD+Left"),
         ("tiling-accordion.png", "Accordion")]
tiles = [(f, c) for f, c in tiles if have(f)]
if tiles:
    rows.append("| " + " | ".join(c for _, c in tiles) + " |")
    rows.append("| " + " | ".join("---" for _ in tiles) + " |")
    rows.append("| " + " | ".join("![%s](docs/%s)" % (c, f) for f, c in tiles) + " |\n")

if not rows:
    print("  no images found, README unchanged")
    sys.exit(0)

block = "<!-- gallery -->\n## Looks like\n\n" + "\n".join(rows) + "\n"
open(readme, "w").write(text.replace("## The key model", block + "\n## The key model", 1))
print("  README gallery added")
