#!/bin/bash

make

install -d "${PREFIX}/bin"
install maf2synteny "${PREFIX}/bin/"
