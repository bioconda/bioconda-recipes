#!/bin/sh

nimble --localdeps build -y --verbose -d:release

mkdir -p "${PREFIX}/bin"
cp somalier "${PREFIX}/bin/"
