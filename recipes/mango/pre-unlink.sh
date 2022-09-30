#!/bin/sh

# disable nbextension
jupyter=${PREFIX}/bin/jupyter
$jupyter nbextension disable bdgenomics.mango.pileup
