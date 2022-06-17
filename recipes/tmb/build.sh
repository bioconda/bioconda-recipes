#!/bin/bash

set -eo pipefail

mkdir -p  "${PREFIX}/bin" "${PREFIX}/config" "${PREFIX}/test"

ls -l *
mv */bin/* "${PREFIX}/bin"
mv */config/* "${PREFIX}/config"
mv */test/* "${PREFIX}/test"
chmod 0755 ${PREFIX}/bin/*
chmod +x ${PREFIX}/bin/*