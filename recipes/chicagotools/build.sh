#!/bin/bash
cd chicagoTools
for fn in \
    bam2chicago.sh \
    fitDistCurve.R \
    makeDesignFiles.py \
    makeNBaitsPerBinFile.py \
    makeNPerBinFile.py \
    makePeakMatrix.R \
    makeProxOEFile.py \
    runChicago.R;
do
    if [ $PY3K == 1 ] && [ "${fn##*.}" = "py" ]; then
        # python files have mostly py2 print statements and an xrange or two. 2to3
        # seems to handle it fine.
        2to3 $fn -w
    fi
    chmod +x $fn
    cp $fn ${PREFIX}/bin
done
cd ..
rm -rf Chicago PCHiCdata

