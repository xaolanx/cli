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

HLS = tuple[float, float, float]


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


def grayscale(hls: HLS, light: bool) -> HLS:
    h, l, s = hls
    return h, 0.5 - l / 2 if light else l / 2 + 0.5, 0


def mix(a: HLS, b: HLS, w: float) -> HLS:
    h1, l1, s1 = a
    h2, l2, s2 = b
    return h1 * (1 - w) + h2 * w, l1 * (1 - w) + l2 * w, s1 * (1 - w) + s2 * w


def darken(colour: HLS, amount: float) -> HLS:
    h, l, s = colour
    return h, max(0, l - amount), s


def distance(colour: HLS, base: str) -> float:
    h1, l1, s1 = colour
    h2, l2, s2 = hex_to_hls(base)
    return abs(h1 - h2) * 0.4 + abs(l1 - l2) * 0.3 + abs(s1 - s2) * 0.3


def smart_sort(colours: list[HLS], base: list[str]) -> dict[str, HLS]:
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

    return {colour_names[i]: c[0] for i, c in enumerate(sorted_colours)}


def get_scheme(scheme: str) -> DynamicScheme:
    if scheme == "content":
        return SchemeContent
    if scheme == "expressive":
        return SchemeExpressive
    if scheme == "fidelity":
        return SchemeFidelity
    if scheme == "fruitsalad":
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
    colours_in = sys.argv[3].split(" ")

    base = light_colours if light else dark_colours
    chroma_mult = 1.5 if light else 1.2

    # Convert to HLS
    colours = [hex_to_hls(c) for c in colours_in[1:]]

    # Sort colours and turn into dict
    colours = smart_sort(colours, base)

    # Adjust colours
    MatScheme = get_scheme(scheme)
    for name, hls in colours.items():
        if scheme == "monochrome":
            colours[name] = grayscale(hls, light)
        else:
            argb = int(f"0xFF{hls_to_hex(*hls)}", 16)
            mat_scheme = MatScheme(Hct.from_int(argb), not light, 0)

            colour = MaterialDynamicColors.primary.get_hct(mat_scheme)

            # Boost neutral scheme colours
            if scheme == "neutral":
                colour.chroma += 10

            colour.chroma *= chroma_mult

            colours[name] = hex_to_hls("{:02X}{:02X}{:02X}".format(*colour.to_rgba()[:3]))

    # Success and error colours
    colours["success"] = mix(colours["green"], hex_to_hls(base[8]), 0.8)
    colours["error"] = mix(colours["red"], hex_to_hls(base[4]), 0.8)

    # Layers and accents
    material = {}
    primary_scheme = MatScheme(Hct.from_int(int(f"0xFF{colours_in[0]}", 16)), not light, 0)
    for colour in vars(MaterialDynamicColors).keys():
        colour_name = getattr(MaterialDynamicColors, colour)
        if hasattr(colour_name, "get_hct"):
            rgb = colour_name.get_hct(primary_scheme).to_rgba()[:3]
            material[colour] = hex_to_hls("{:02X}{:02X}{:02X}".format(*rgb))

    colours["primary"] = material["primary"]
    colours["secondary"] = material["secondary"]
    colours["tertiary"] = material["tertiary"]
    colours["text"] = material["onBackground"]
    colours["subtext1"] = material["onSurfaceVariant"]
    colours["subtext0"] = material["outline"]
    colours["overlay2"] = mix(material["surface"], material["outline"], 0.86)
    colours["overlay1"] = mix(material["surface"], material["outline"], 0.71)
    colours["overlay0"] = mix(material["surface"], material["outline"], 0.57)
    colours["surface2"] = mix(material["surface"], material["outline"], 0.43)
    colours["surface1"] = mix(material["surface"], material["outline"], 0.29)
    colours["surface0"] = mix(material["surface"], material["outline"], 0.14)
    colours["base"] = material["surface"]
    colours["mantle"] = darken(material["surface"], 0.03)
    colours["crust"] = darken(material["surface"], 0.05)

    for name, colour in colours.items():
        print(f"{name} {hls_to_hex(*colour)}")
