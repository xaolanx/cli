#!/bin/python

import math
import sys
from colorsys import hls_to_rgb, rgb_to_hls

from materialyoucolor.dynamiccolor.material_dynamic_colors import MaterialDynamicColors
from materialyoucolor.hct import Hct
from materialyoucolor.quantize import ImageQuantizeCelebi
from materialyoucolor.scheme.scheme_content import SchemeContent
from materialyoucolor.scheme.scheme_expressive import SchemeExpressive
from materialyoucolor.scheme.scheme_fidelity import SchemeFidelity
from materialyoucolor.scheme.scheme_fruit_salad import SchemeFruitSalad
from materialyoucolor.scheme.scheme_monochrome import SchemeMonochrome
from materialyoucolor.scheme.scheme_neutral import SchemeNeutral
from materialyoucolor.scheme.scheme_rainbow import SchemeRainbow
from materialyoucolor.scheme.scheme_tonal_spot import SchemeTonalSpot
from materialyoucolor.scheme.scheme_vibrant import SchemeVibrant
from materialyoucolor.score.score import Score


def darken(rgb: tuple[int, int, int], amount: float) -> tuple[int, int, int]:
    h, l, s = rgb_to_hls(*tuple(i / 255 for i in rgb))
    return tuple(round(i * 255) for i in hls_to_rgb(h, max(0, l - amount), s))


def mix(
    rgb1: tuple[int, int, int], rgb2: tuple[int, int, int], amount: float
) -> tuple[int, int, int]:
    return tuple(round(rgb1[i] * (1 - amount) + rgb2[i] * amount) for i in range(3))


num_args = len(sys.argv)
if num_args < 2:
    print('Usage: <path/to/image> [ "light" | "dark" ]')
    sys.exit(1)

img = sys.argv[1]
is_dark = num_args < 3 or sys.argv[2] != "light"

colours = ImageQuantizeCelebi(img, 1, 128)
hct = Hct.from_int(Score.score(colours)[0])

for Scheme in (
    SchemeFruitSalad,
    SchemeExpressive,
    SchemeMonochrome,
    SchemeRainbow,
    SchemeTonalSpot,
    SchemeNeutral,
    SchemeFidelity,
    SchemeContent,
    SchemeVibrant,
):
    print("\n" + Scheme.__name__[6:].lower())
    scheme = Scheme(hct, is_dark, 0.0)

    colours = {}

    for color in vars(MaterialDynamicColors).keys():
        color_name = getattr(MaterialDynamicColors, color)
        if hasattr(color_name, "get_hct"):
            colours[color] = color_name.get_hct(scheme).to_rgba()[:3]

    colours = {
        "primary": colours["primary"],
        "secondary": colours["secondary"],
        "tertiary": colours["tertiary"],
        "text": colours["onBackground"],
        "subtext1": colours["onSurfaceVariant"],
        "subtext0": colours["outline"],
        "overlay2": mix(colours["surface"], colours["outline"], 0.86),
        "overlay1": mix(colours["surface"], colours["outline"], 0.71),
        "overlay0": mix(colours["surface"], colours["outline"], 0.57),
        "surface2": mix(colours["surface"], colours["outline"], 0.43),
        "surface1": mix(colours["surface"], colours["outline"], 0.29),
        "surface0": mix(colours["surface"], colours["outline"], 0.14),
        "base": colours["surface"],
        "mantle": darken(colours["surface"], 0.03),
        "crust": darken(colours["surface"], 0.05),
    }

    for name, colour in colours.items():
        print("{} {:02X}{:02X}{:02X}".format(name, *colour))
