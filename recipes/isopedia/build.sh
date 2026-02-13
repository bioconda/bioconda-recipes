#!/bin/bash



mkdir -p ${PREFIX}/bin
cp isopedia ${PREFIX}/bin
cp isopedia-tools ${PREFIX}/bin
cp isopedia-splice-viz.py ${PREFIX}/bin
cp isopedia-splice-viz-temp.html ${PREFIX}/bin
chmod +x ${PREFIX}/bin/isopedia-splice-viz.py
chmod +x ${PREFIX}/bin/isopedia
chmod +x ${PREFIX}/bin/isopedia-tools
