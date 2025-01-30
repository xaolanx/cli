#!/bin/python3

import sys
from colorsys import rgb_to_hls

if __name__ == "__main__":
    for arg in sys.argv[1:]:
        print(rgb_to_hls(*tuple(int(arg[i:i+2], 16) for i in (0, 2, 4)))[1])
