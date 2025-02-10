#!/bin/bash -euo

mkdir -p $PREFIX/bin

RUST_BACKTRACE=1 cargo install --no-track --verbose --root "${PREFIX}" --path .

SCRIPTS="block.py core.py multi.auto.py multi.correlate.py multi.heatmap.py multi.histogram.py multi.scatter.py nwindow.py path.py ps.py saturation_plotter.py stats_path.py window.py"

for SCRIPT in ${SCRIPTS} ; do
    cp scripts/${SCRIPT} ${PREFIX}/bin/${SCRIPT}
    chmod +x ${PREFIX}/bin/${SCRIPT}
done
