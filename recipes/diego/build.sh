#!/bin/bash

mkdir -p ${PREFIX}/bin

chmod +x DIEGO/*.py
chmod +x DIEGO/*.pl

mv DIEGO/*.py ${PREFIX}/bin/
mv DIEGO/*.pl ${PREFIX}/bin/

touch LICENSE					# This has to be removed once the LICENSE file was added upstream, so far this information is only available at the website
