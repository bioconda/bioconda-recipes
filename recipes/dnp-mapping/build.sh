#!/bin/bash

make mapping_CC
install -d "${PREFIX}/bin"
install mapping_CC "${PREFIX}/bin/dnp-mapping"
