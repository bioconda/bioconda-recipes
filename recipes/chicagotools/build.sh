#!/bin/bash
cd chicagoTools
chmod +x {bam2chicago.sh,fitDistCurve.R,makeDesignFiles.py,makeNBaitsPerBinFile.py,makeNPerBinFile.py,makePeakMatrix.R,makeProxOEFile.py,runChicago.R}
cp {bam2chicago.sh,fitDistCurve.R,makeDesignFiles.py,makeNBaitsPerBinFile.py,makeNPerBinFile.py,makePeakMatrix.R,makeProxOEFile.py,runChicago.R} ${PREFIX}/bin
cd ..
rm -rf chicago