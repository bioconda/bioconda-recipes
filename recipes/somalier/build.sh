#!/bin/bash

mkdir -p "${PREFIX}/bin"

nimble --localdeps build -y --verbose -d:release

install -v -m 0755 somalier "${PREFIX}/bin"
