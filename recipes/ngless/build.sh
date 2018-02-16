#!/bin/bash
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"
export CFLAGS="-I$PREFIX/include"
export CPATH=${PREFIX}/include

# internal download failes with:
# ERROR: cannot verify github.com's certificate, issued by ‘CN=DigiCert SHA2 Extended Validation Server CA,OU=www.digicert.com,O=DigiCert Inc,C=US’:
# Unable to locally verify the issuer's authority.
#
alias wget='wget --no-check-certificate'

stack setup
stack update
make install prefix=$PREFIX

#cleanup
rm -r .stack-work
