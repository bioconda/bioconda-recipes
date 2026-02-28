#!/bin/bash

make
install -d "${PREFIX}/bin"
install bin/peakranger "${PREFIX}/bin/"
