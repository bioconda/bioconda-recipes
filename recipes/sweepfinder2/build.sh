#!/bin/bash

make
install -d "${PREFIX}/bin"
install SweepFinder2 "${PREFIX}/bin/"
