#!/bin/bash
set -x
mkdir -p "${PREFIX}/bin"
install -v -m 0755 bigwig "${PREFIX}/bin"
