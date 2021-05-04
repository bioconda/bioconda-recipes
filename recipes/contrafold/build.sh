cd ./src
make clean
make

mkdir -p $PREFIX/shared/contrafold
mkdir -p $PREFIX/bin

cp Contrafold.o Defaults.ipp FileDescription.o Options.o SStruct.o ScorePrediction.o Utilities.o contrafold score_prediction $PREFIX/shared/contrafold/
ln -s $PREFIX/bin/contrafold $PREFIX/shared/contrafold/contrafold
ln -s $PREFIX/bin/score_prediction $PREFIX/shared/contrafold/score_prediction
