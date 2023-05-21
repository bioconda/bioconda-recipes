#!/bin/sh
set -eu -o pipefail

c++ NLStradamus.cpp -o NLStradamus -O3

mv NLStradamus $PREFIX/bin
