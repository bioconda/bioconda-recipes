#!/bin/bash

set -e

ImageJ --ij2 --headless --console -macro basic.ijm "$PWD" | grep "grains-Erosion"
echo PASS
