#!/usr/bin/env bash

mkdir -p "${PREFIX}/bin" "${PREFIX}/example_data"
chmod +x bin/*
cp bin/* "${PREFIX}/bin/"
cp example_data/* "${PREFIX}/example_data/"
