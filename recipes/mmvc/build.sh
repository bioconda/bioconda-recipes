#!/bin/bash

# circumvent a bug in conda-build >=2.1.18,<3.0.10
# https://github.com/conda/conda-build/issues/2255
[[ -z $REQUESTS_CA_BUNDLE && ${REQUESTS_CA_BUNDLE+x} ]] && unset REQUESTS_CA_BUNDLE
[[ -z $SSL_CERT_FILE && ${SSL_CERT_FILE+x} ]] && unset SSL_CERT_FILE

julia -e 'Pkg.add("ArgParse")'
julia -e 'Pkg.add("FastaIO")'
julia -e 'Pkg.add("JSON")'

cp mmvc.jl $PREFIX/bin/mmvc
