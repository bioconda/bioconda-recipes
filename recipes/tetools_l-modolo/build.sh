#!/bin/bash

mkdir -p $PREFIX/bin
sed -i 's|#!/usr/bin/Rscript|#!/usr/bin/env Rscript|' TEdiff.R
sed -i 's|#!/usr/bin/python3|#!/usr/bin/env python|' TEcount.py
sed -i 's|#!/usr/bin/python3|#!/usr/bin/env python|' PingPong.py
EXEC='PingPong.py TEcount.py TEdiff.R UrQt pingpongpro/pingpongpro'
chmod +x $EXEC
cp $EXEC $PREFIX/bin/
