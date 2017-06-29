#!/bin/bash

mkdir -p $PREFIX/bin

bash install_dDocent_requirements $PREFIX/bin

chmod +x $PREFIX/bin/dDocent
