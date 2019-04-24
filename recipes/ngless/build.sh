#!/usr/bin/env bash


mkdir -p ${PREFIX}/bin
mv ngless-1.0.0-static-Linux64 ngless
chmod +x ngless
mv ngless ${PREFIX}/bin
