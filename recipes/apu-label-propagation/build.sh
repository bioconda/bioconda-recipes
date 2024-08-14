#!/bin/bash
mkdir -p ${PREFIX}/bin

cp ./apu-label-propagation ${PREFIX}/bin/

chmod g+w ${PREFIX}/bin/apu-label-propagation
