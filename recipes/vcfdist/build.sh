#!/bin/bash

make
install -d "${PREFIX}/bin"
install vcfdist "${PREFIX}/bin"
