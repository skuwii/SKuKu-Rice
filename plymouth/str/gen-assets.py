#!/usr/bin/env python3
# Generates dot.png for the STR Plymouth spinner theme
from PIL import Image, ImageDraw
import os

size = 18
img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Azure #2980d4 filled circle with 1px anti-alias margin
draw.ellipse([1, 1, size - 2, size - 2], fill=(41, 128, 212, 255))

out = os.path.join(os.path.dirname(__file__), "dot.png")
img.save(out)
print(f"Generated {out}")
