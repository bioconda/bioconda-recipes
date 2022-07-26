cd ./src
make clean
make

mkdir -p $PREFIX/shared/contrafold
mkdir -p $PREFIX/bin

cp Contrafold.o Defaults.ipp FileDescription.o Options.o SStruct.o ScorePrediction.o Utilities.o contrafold score_prediction $PREFIX/shared/contrafold/
ln -s $PREFIX/shared/contrafold/contrafold $PREFIX/bin/contrafold
ln -s $PREFIX/shared/contrafold/score_prediction $PREFIX/bin/score_prediction
