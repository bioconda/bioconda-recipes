#!/usr/bin/env bash

mkdir -p "${PREFIX}/bin" "${PREFIX}/db"
chmod +x bin/*
cp bin/* "${PREFIX}/bin/"
cp db/* "${PREFIX}/db/"
