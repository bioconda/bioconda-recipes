#!/bin/sh
set -e

mkdir -p "${PREFIX}/bin" "${PREFIX}/db"
mv bin/* "${PREFIX}/bin/"
mv db/* "${PREFIX}/db/"

