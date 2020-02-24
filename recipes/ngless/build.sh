#!/usr/bin/env bash


mkdir -p ${PREFIX}/bin
mv NGLess-1.1.0-static-Linux64 ngless
chmod +x ngless
mv ngless ${PREFIX}/bin
