#!/bin/bash

mkdir -p $PREFIX/bin

cp psQTL_prep.py $PREFIX/bin/psQTL_prep.py
cp psQTL_prep.py $PREFIX/bin/psQTL_prep
cp psQTL_proc.py $PREFIX/bin/psQTL_proc.py
cp psQTL_proc.py $PREFIX/bin/psQTL_proc
cp psQTL_post.py $PREFIX/bin/psQTL_post.py
cp psQTL_post.py $PREFIX/bin/psQTL_post
cp _version.py $PREFIX/bin/_version.py

mkdir -p $PREFIX/bin/modules
cp -r modules/* $PREFIX/bin/modules/

mkdir -p $PREFIX/bin/tests
cp -r tests/* $PREFIX/bin/tests/

mkdir -p $PREFIX/bin/utilities
cp utilities/integrative_splsda.R $PREFIX/bin/utilities/integrative_splsda.R
cp utilities/windowed_splsda.R $PREFIX/bin/utilities/windowed_splsda.R

chmod a+x $PREFIX/bin/psQTL_prep
chmod a+x $PREFIX/bin/psQTL_proc
chmod a+x $PREFIX/bin/psQTL_post
