#!/bin/bash

mkdir -p ${PREFIX}/bin

export FFLAGS="-O3 -ffast-math -lm -Wno-deprecated-declarations"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

if [[ `uname` == "Darwin" ]]; then
	rm -f TMalign.cpp TMscore.cpp
	cp -rf ${RECIPE_DIR}/TMalign.cpp .
	wget https://zhanggroup.org/TM-score/TMscore.cpp
	${CXX} ${FFLAGS} -o "${PREFIX}/bin/TMalign" TMalign.cpp
	${CXX} ${FFLAGS} -o "${PREFIX}/bin/TMscore" TMscore.cpp
else
	rm -f TMalign.cpp TMscore.cpp
	wget https://seq2fun.dcmb.med.umich.edu//TM-align/TMalign.cpp
	wget https://zhanggroup.org/TM-score/TMscore.cpp
	${CXX} ${FFLAGS} -static -o "${PREFIX}/bin/TMalign" TMalign.cpp
	${CXX} ${FFLAGS} -static -o "${PREFIX}/bin/TMscore" TMscore.cpp
fi
