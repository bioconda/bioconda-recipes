#!/bin/bash

cp *.pl ${PREFIX}/bin
cp *.sh ${PREFIX}/bin

chmod +x ${PREFIX}/bin/*.pl
chmod +x ${PREFIX}/bin/*.sh
