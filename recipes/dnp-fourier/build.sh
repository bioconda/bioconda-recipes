#!/bin/bash

make fourier
install -d "${PREFIX}/bin"
install fourier "${PREFIX}/bin/dnp-fourier"
