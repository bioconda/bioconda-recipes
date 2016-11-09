#!/bin/bash
cd chicagoTools
cp {bam2chicago.sh,fitDistCurve.R,makeDesignFiles.py,makeNBaitsPerBinFile.py,makeNPerBinFile.py,makePeakMatrix.R,makeProxOEFile.py,runChicago.R} ${PREFIX}/bin
chmod +x {bam2chicago.sh,fitDistCurve.R,makeDesignFiles.py,makeNBaitsPerBinFile.py,makeNPerBinFile.py,makePeakMatrix.R,makeProxOEFile.py,runChicago.R}
cd ..
rm -rf chicago