
#!/bin/bash

# R refuses to build packages that mark themselves as
# "Priority: Recommended"
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
#
$R CMD INSTALL --build .

#ls -l $PREFIX
#ln -s $PREFIX/lib/R/library/DESeq2/script/deseq2.R $PREFIX/bin
#ls -l $PREFIX/bin
echo '#!/usr/bin/env Rscript' > foo.R
echo 'useTXI <- FALSE' >> foo.R
cat $PREFIX/lib/R/library/DESeq2/script/deseq2.R >> foo.R
cp foo.R $PREFIX/bin/deseq2.R
chmod +x $PREFIX/bin/deseq2.R
#
# # Add more build steps here, if they are necessary.
#
# See
# http://docs.continuum.io/conda/build.html
# for a list of environment variables that are set during the build
# process.
# 
