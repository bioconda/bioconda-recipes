#!/bin/bash

set -e

ImageJ --ij2 --headless --console --run test.groovy
echo PASS
