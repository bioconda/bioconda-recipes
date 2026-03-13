#!/bin/bash

mkdir -p "${PREFIX}/bin"

make CC="${CC}"

make install CC="${CC}"
