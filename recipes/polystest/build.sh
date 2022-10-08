#!/bin/bash

# move all files to outdir and link into it by bin executor
mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share/polystest
# substituting paths for testing 
cp run_app_conda.R run_polystest_app.R
sed -i'.orig' "s=HelperFuncs.R=../share/polystest/HelperFuncs.R=" runPolySTestCLI.R
sed -i'.orig' "s=rankprodbounds.R=../share/polystest/rankprodbounds.R=" HelperFuncs.R

# copying files
cp *.R $PREFIX/share/polystest/
cp LiverAllProteins.csv $PREFIX/share/polystest/
cp polystest.yml $PREFIX/share/polystest/
cp runPolySTestCLI.R $PREFIX/bin
cp convertFromProline.R $PREFIX/bin
cp run_polystest_app.R $PREFIX/bin
echo "before chmod"
chmod a+x $PREFIX/bin/runPolySTestCLI.R
chmod a+x $PREFIX/bin/run_polystest_app.R




