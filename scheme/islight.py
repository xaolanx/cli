#!/bin/python

import sys
from PIL import Image
from materialyoucolor.quantize import QuantizeCelebi
from materialyoucolor.score.score import Score
from materialyoucolor.hct import Hct
from resizeimg import resize


if __name__ == "__main__":
    with Image.open(sys.argv[1]) as img:
        img = resize(img)[0]
        colours = QuantizeCelebi(list(img.getdata()), 128)
        hct = Hct.from_int(Score.score(colours)[0])
        sys.exit(0 if hct.tone > 60 else 1)
