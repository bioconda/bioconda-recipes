#!/bin/bash -e

# Circumvent bug (share/julia/cert.pem not found)
# https://github.com/fonsp/Pluto.jl/issues/2221
ln -s $PREFIX/ssl/cert.pem $PREFIX/share/julia/cert.pem

