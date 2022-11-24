export PREFIX=${PREFIX}
make GCC=$CC --file=makefile-conda.mk

cp cvlr-cluster ${PREFIX}/bin/.
cp cvlr-meth-of-bam  ${PREFIX}/bin/.
cp *py ${PREFIX}/bin/.


