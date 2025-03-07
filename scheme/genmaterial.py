#!/bin/python

import math
import sys
from colorsys import hls_to_rgb, rgb_to_hls

from materialyoucolor.dynamiccolor.material_dynamic_colors import MaterialDynamicColors
from materialyoucolor.hct import Hct
from materialyoucolor.quantize import QuantizeCelebi
from materialyoucolor.score.score import Score
from PIL import Image


def darken(rgb: tuple[int, int, int], amount: float) -> tuple[int, int, int]:
    h, l, s = rgb_to_hls(*tuple(i / 255 for i in rgb))
    return tuple(round(i * 255) for i in hls_to_rgb(h, max(0, l - amount), s))


def mix(
    rgb1: tuple[int, int, int], rgb2: tuple[int, int, int], amount: float
) -> tuple[int, int, int]:
    return tuple(round(rgb1[i] * (1 - amount) + rgb2[i] * amount) for i in range(3))


def calculate_optimal_size(
    width: int, height: int, bitmap_size: int = 128
) -> (int, int):
    image_area = width * height
    bitmap_area = bitmap_size**2
    scale = math.sqrt(bitmap_area / image_area) if image_area > bitmap_area else 1
    return max(1, round(width * scale)), max(1, round(height * scale))


num_args = len(sys.argv)
if num_args < 2:
    print('Usage: <path/to/image> [ "light" | "dark" ] [ <material_scheme> ]')
    sys.exit(1)

img = sys.argv[1]
is_dark = num_args < 3 or sys.argv[2] != "light"
scheme = "vibrant" if num_args < 4 else sys.argv[3]

with Image.open(sys.argv[1]) as image:
    if image.format == "GIF":
        image.seek(1)

    if image.mode in ["L", "P"]:
        image = image.convert("RGB")

    width, height = image.size
    opt_width, opt_height = calculate_optimal_size(width, height)
    if opt_width < width or opt_height < height:
        image = image.resize((opt_width, opt_height), Image.Resampling.BICUBIC)
    colours = QuantizeCelebi(list(image.getdata()), 128)

    hct = Hct.from_int(Score.score(colours)[0])


if scheme == "fruitsalad":
    from materialyoucolor.scheme.scheme_fruit_salad import SchemeFruitSalad as Scheme
elif scheme == "expressive":
    from materialyoucolor.scheme.scheme_expressive import SchemeExpressive as Scheme
elif scheme == "monochrome":
    from materialyoucolor.scheme.scheme_monochrome import SchemeMonochrome as Scheme
elif scheme == "rainbow":
    from materialyoucolor.scheme.scheme_rainbow import SchemeRainbow as Scheme
elif scheme == "tonalspot":
    from materialyoucolor.scheme.scheme_tonal_spot import SchemeTonalSpot as Scheme
elif scheme == "neutral":
    from materialyoucolor.scheme.scheme_neutral import SchemeNeutral as Scheme
elif scheme == "fidelity":
    from materialyoucolor.scheme.scheme_fidelity import SchemeFidelity as Scheme
elif scheme == "content":
    from materialyoucolor.scheme.scheme_content import SchemeContent as Scheme
else:
    from materialyoucolor.scheme.scheme_vibrant import SchemeVibrant as Scheme


scheme = Scheme(hct, is_dark, 0.0)


colours = {}

for color in vars(MaterialDynamicColors).keys():
    color_name = getattr(MaterialDynamicColors, color)
    if hasattr(color_name, "get_hct"):
        colours[color] = color_name.get_hct(scheme).to_rgba()[0:3]

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
    "accent": colours["primary"],  # FIXME: for compatibility
}

for name, colour in colours.items():
    print("{} {:02X}{:02X}{:02X}".format(name, *colour))
