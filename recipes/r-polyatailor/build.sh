#!/bin/bash

export DISABLE_AUTOBREW=1

# Unzip the ggmsa.zip dependency located inside the polyAtailor package
unzip patch/ggmsa.zip -d /tmp/ggmsa

# Install the ggmsa package
$R CMD INSTALL /tmp/ggmsa/ggmsa

# Install the main polyAtailor package
$R CMD INSTALL --build .
