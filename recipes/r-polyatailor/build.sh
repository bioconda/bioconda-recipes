#!/bin/bash

export DISABLE_AUTOBREW=1

# Unzip the main polyAtailor source to a temporary directory
unzip PolyAtailor-master.zip -d /tmp/polyAtailor

# Unzip the ggmsa.zip dependency located inside the polyAtailor package
unzip /tmp/polyAtailor/patch/ggmsa.zip -d /tmp/ggmsa

# Install the ggmsa package
$R CMD INSTALL /tmp/ggmsa

# Install the main polyAtailor package
$R CMD INSTALL --build .
