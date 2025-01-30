#!/bin/python3

import sys
from colorsys import rgb_to_hls, hls_to_rgb

def hex_to_rgb(hex: str) -> tuple[int, int, int]:
    """Convert a hex string to an RGB tuple in the range [0, 1]."""
    return tuple(int(hex[i:i+2], 16) / 255 for i in (0, 2, 4))

def hex_to_hls(hex: str) -> tuple[float, float, float]:
    return rgb_to_hls(*hex_to_rgb(hex))

def adjust_saturation(hex: str, amount: float,) -> str:
    h, l, s = hex_to_hls(hex)
    s = max(0, min(1, s + amount))
    return "".join(f"{round(i * 255):02X}" for i in hls_to_rgb(h, l, s))

if __name__ == "__main__":
    light = sys.argv[1] == "light"

    added_sat = 0.25 if light else 0.1

    for colour in sys.argv[3].split(" ")[1:]:
        print(adjust_saturation(colour, added_sat))

    for layer in sys.argv[4:]:
        print(layer.split(" ")[0])
