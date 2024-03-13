#!/bin/bash

set -eux

make tests-shlib

PATH="$PWD:$PATH" python allTests.py
