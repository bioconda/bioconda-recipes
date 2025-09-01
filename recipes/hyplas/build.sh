#!/bin/bash
${PYTHON} installer.py ${PREFIX} --tool HyPlAs --skip  pandas numpy packaging platon spades racon minigraph minimap2
${PYTHON} -m pip install . --no-deps -vvv
