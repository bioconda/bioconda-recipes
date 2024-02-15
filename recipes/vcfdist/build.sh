#!/bin/bash

cd src
make
install -d "${PREFIX}/bin"
install vcfdist "${PREFIX}/bin"
