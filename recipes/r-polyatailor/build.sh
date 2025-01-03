#!/bin/bash

export DISABLE_AUTOBREW=1
unzip patch/ggmsa.zip -d /tmp
$R CMD INSTALL /tmp/ggmsa
$R CMD INSTALL --build .
