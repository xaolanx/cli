#!/bin/python

import sys
import math
from PIL import Image


def calc_size(w, h, b = 128):
    ia = w * h
    ba = b * b
    s = math.sqrt(ba / ia) if ia > ba else 1
    return max(1, round(w * s)), max(1, round(h * s))


def resize(img):
    w, h = calc_size(img.width, img.height)
    if w < img.width or h < img.height:
        return img.resize((w, h), Image.Resampling.BICUBIC), True
    return img, False


if __name__ == "__main__":
    with Image.open(sys.argv[1]) as img:
        img, resized = resize(img)
        if resized:
            img.save("/tmp/caelestia-resize.png")
            print("/tmp/caelestia-resize.png")
        else:
            print(sys.argv[1])
