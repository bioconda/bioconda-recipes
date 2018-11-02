#!/usr/bin/env bash

echo "
####################################################################################
${PKG_NAME} version ${PKG_VERSION}-${PKG_BUILDNUM} has been successfully installed!

This software by default runs with USEARCH. You can install it from the following links or use DIAMOND '--search_engine diamond'

 > Download: http://www.drive5.com/usearch/download.html
 > Installation instruction: http://www.drive5.com/usearch/manual/install.html
 " > $PREFIX/.messages.txt
