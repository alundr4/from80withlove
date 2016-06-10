#!/bin/bash

../../bin/pcx2snes-linux-x64 demo_sprites -s32 -c16 -o32 -n
../../bin/pcx2snes-linux-x64 scene2_bg -s8 -c128 -o128 -n -screen
../../bin/pcx2snes-linux-x64 scene1_logo  -s8 -c256 -o256 -n -screen

