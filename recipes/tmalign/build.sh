#!/bin/bash

mkdir -p ${PREFIX}/bin

export FFLAGS="-O3 -ffast-math -lm -Wno-deprecated-declarations"
export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"

# backup to "gfortran" in conda GFORTRAN is not set
export GFORTRAN=${GFORTRAN:-gfortran}

if [[ `uname` == "Darwin" ]]; then
	rm TMalign.cpp
	cp -rf ${RECIPE_DIR}/TMalign.cpp .
	${CXX} ${FFLAGS} -o "${PREFIX}/bin/TMalign" TMalign.cpp
	${GFORTRAN} ${FFLAGS} -o "${PREFIX}/bin/TMscore" TMscore.f
else
	rm TMalign.cpp
	wget https://seq2fun.dcmb.med.umich.edu//TM-align/TMalign.cpp
	${CXX} ${FFLAGS} -static -o "${PREFIX}/bin/TMalign" TMalign.cpp
	${GFORTRAN} ${FFLAGS} -static -o "${PREFIX}/bin/TMscore" TMscore.f
fi
