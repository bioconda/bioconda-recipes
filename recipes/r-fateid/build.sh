LD_LIBRARY_PATH=${BUILD_PREFIX}/x86_64-conda_cos6-linux-gnu/sysroot/usr/lib64
export DISABLE_AUTOBREW=1
mv DESCRIPTION DESCRIPTION.old
grep -v '^Priority: ' DESCRIPTION.old > DESCRIPTION
$R CMD INSTALL --build .
