#!/bin/bash

sed -i "s|DEST_HOME=.*|DEST_HOME=$PREFIX|" install.sh
./install.sh

rm -r $PREFIX/man
rm -r $PREFIX/share

