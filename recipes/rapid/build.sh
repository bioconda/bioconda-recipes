#!/bin/bash

chmod 755 bin/*
mkdir -p "${PREFIX}/bin"
mv bin/* "${PREFIX}/bin/"
