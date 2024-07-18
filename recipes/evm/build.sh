#!/bin/bash

mkdir -p ${PREFIX}/bin
chmod +x EvmUtils/*.pl
cp EvmUtils/*.pl ${PREFIX}/bin/
cp PerlLib/*.pm ${PREFIX}/bin/
chmod +x EVidenceModeler
cp EVidenceModeler ${PREFIX}/bin/
