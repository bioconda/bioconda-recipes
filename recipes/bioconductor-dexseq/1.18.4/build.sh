
#!/bin/bash

# R refuses to build packages that mark themselves as
# "Priority: Recommended"
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
#
$R CMD INSTALL --build .

python_scripts=$PREFIX/lib/R/library/DEXSeq/python_scripts

sed -i "1i #!/usr/bin/env python" $python_scripts/dexseq_count.py
sed -i "1i #!/usr/bin/env python" $python_scripts/dexseq_prepare_annotation.py

chmod +x $python_scripts/dexseq_count.py
chmod +x $python_scripts/dexseq_prepare_annotation.py

mkdir -p $PREFIX/bin
ln -s $python_scripts/dexseq_count.py $PREFIX/bin/dexseq_count.py
ln -s $python_scripts/dexseq_prepare_annotation.py $PREFIX/bin/dexseq_prepare_annotation.py
#
# # Add more build steps here, if they are necessary.
#
# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build
# process.
#
