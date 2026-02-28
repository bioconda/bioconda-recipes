#!/usr/bin/env bash

echo "
####################################################################################
${PKG_NAME} version ${PKG_VERSION}-${PKG_BUILDNUM} has been successfully installed!

This version uses DIAMOND as default alignment tool. As an alternative, USEARCH can be installed from the following links

 > Download: http://www.drive5.com/usearch/download.html
 > Installation instruction: http://www.drive5.com/usearch/manual/install.html
 " > $PREFIX/.messages.txt
