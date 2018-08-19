#!/usr/bin/env bash

echo "
####################################################################################
${PKG_NAME} version ${PKG_VERSION}-${PKG_BUILDNUM} has been successfully installed!

This software also need USEARCH version 8.1 or more. Bioconda can not provide it
because of its license.

 > Download: http://www.drive5.com/usearch/download.html
 > Installation instruction: http://www.drive5.com/usearch/manual/install.html
 " > $PREFIX/.messages.txt
