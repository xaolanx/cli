#!/bin/python3

import sys
from colorsys import hls_to_rgb, rgb_to_hls

from materialyoucolor.dynamiccolor.material_dynamic_colors import (
    DynamicScheme,
    MaterialDynamicColors,
)
from materialyoucolor.hct import Hct
from materialyoucolor.scheme.scheme_content import SchemeContent
from materialyoucolor.scheme.scheme_expressive import SchemeExpressive
from materialyoucolor.scheme.scheme_fidelity import SchemeFidelity
from materialyoucolor.scheme.scheme_fruit_salad import SchemeFruitSalad
from materialyoucolor.scheme.scheme_monochrome import SchemeMonochrome
from materialyoucolor.scheme.scheme_neutral import SchemeNeutral
from materialyoucolor.scheme.scheme_rainbow import SchemeRainbow
from materialyoucolor.scheme.scheme_tonal_spot import SchemeTonalSpot
from materialyoucolor.scheme.scheme_vibrant import SchemeVibrant
from materialyoucolor.utils.color_utils import argb_from_rgb

light_colours = [
    "dc8a78",
    "dd7878",
    "ea76cb",
    "8839ef",
    "d20f39",
    "e64553",
    "fe640b",
    "df8e1d",
    "40a02b",
    "179299",
    "04a5e5",
    "209fb5",
    "1e66f5",
    "7287fd",
]

dark_colours = [
    "f5e0dc",
    "f2cdcd",
    "f5c2e7",
    "cba6f7",
    "f38ba8",
    "eba0ac",
    "fab387",
    "f9e2af",
    "a6e3a1",
    "94e2d5",
    "89dceb",
    "74c7ec",
    "89b4fa",
    "b4befe",
]

colour_names = [
    "rosewater",
    "flamingo",
    "pink",
    "mauve",
    "red",
    "maroon",
    "peach",
    "yellow",
    "green",
    "teal",
    "sky",
    "sapphire",
    "blue",
    "lavender",
    "success",
    "error",
]


def hex_to_rgb(hex: str) -> tuple[float, float, float]:
    """Convert a hex string to an RGB tuple in the range [0, 1]."""
    return tuple(int(hex[i : i + 2], 16) / 255 for i in (0, 2, 4))


def rgb_to_hex(rgb: tuple[float, float, float]) -> str:
    """Convert an RGB tuple in the range [0, 1] to a hex string."""
    return "".join(f"{round(i * 255):02X}" for i in rgb)


def hex_to_hls(hex: str) -> tuple[float, float, float]:
    return rgb_to_hls(*hex_to_rgb(hex))


def hls_to_hex(h: str, l: str, s: str) -> str:
    return rgb_to_hex(hls_to_rgb(h, l, s))


def adjust(hex: str, light: float = 0, sat: float = 0) -> str:
    h, l, s = hex_to_hls(hex)
    return hls_to_hex(h, max(0, min(1, l + light)), max(0, min(1, s + sat)))


def grayscale(hex: str, light: bool) -> str:
    h, l, s = hex_to_hls(hex)
    return hls_to_hex(h, 0.5 - l / 2 if light else l / 2 + 0.5, 0)


def distance(colour: str, base: str) -> float:
    h1, l1, s1 = hex_to_hls(colour)
    h2, l2, s2 = hex_to_hls(base)
    return abs(h1 - h2) * 0.4 + abs(l1 - l2) * 0.3 + abs(s1 - s2) * 0.3


def smart_sort(colours: list[str], base: list[str]) -> list[str]:
    sorted_colours = [None] * len(colours)
    distances = {}

    for colour in colours:
        dist = [(i, distance(colour, b)) for i, b in enumerate(base)]
        dist.sort(key=lambda x: x[1])
        distances[colour] = dist

    for colour in colours:
        while len(distances[colour]) > 0:
            i, dist = distances[colour][0]

            if sorted_colours[i] is None:
                sorted_colours[i] = colour, dist
                break
            elif sorted_colours[i][1] > dist:
                old = sorted_colours[i][0]
                sorted_colours[i] = colour, dist
                colour = old

            distances[colour].pop(0)

    return [i[0] for i in sorted_colours]


def mix(a: str, b: str, w: float) -> str:
    r1, g1, b1 = hex_to_rgb(a)
    r2, g2, b2 = hex_to_rgb(b)
    return rgb_to_hex(
        (r1 * (1 - w) + r2 * w, g1 * (1 - w) + g2 * w, b1 * (1 - w) + b2 * w)
    )


def get_scheme(scheme: str) -> DynamicScheme:
    if scheme == "content":
        return SchemeContent
    if scheme == "expressive":
        return SchemeExpressive
    if scheme == "fidelity":
        return SchemeFidelity
    if scheme == "fruitSalad":
        return SchemeFruitSalad
    if scheme == "monochrome":
        return SchemeMonochrome
    if scheme == "neutral":
        return SchemeNeutral
    if scheme == "rainbow":
        return SchemeRainbow
    if scheme == "tonalspot":
        return SchemeTonalSpot
    return SchemeVibrant


if __name__ == "__main__":
    light = sys.argv[1] == "light"
    scheme = sys.argv[2]
    colours_in = sys.argv[3]

    base = light_colours if light else dark_colours
    MatScheme = get_scheme(scheme)

    colours = smart_sort(colours_in.split(" "), base)
    for i, hex in enumerate(colours):
        if scheme == "monochrome":
            colours[i] = grayscale(hex, light)
        else:
            argb = argb_from_rgb(int(hex[:2], 16), int(hex[2:4], 16), int(hex[4:], 16))
            mat_scheme = MatScheme(Hct.from_int(argb), not light, 0)
            primary = MaterialDynamicColors.primary.get_hct(mat_scheme)
            colours[i] = "{:02X}{:02X}{:02X}".format(*primary.to_rgba()[:3])

    # Success and error colours
    colours.append(mix(colours[8], base[8], 0.8))  # Success (green)
    colours.append(mix(colours[4], base[4], 0.8))  # Error (red)

    for i, colour in enumerate(colours):
        print(f"{colour_names[i]} {colour}")
