#!/bin/bash

mkdir -p $PREFIX/lib/R/library/pathphynder
cp -r R/ data/ inst/ $PREFIX/lib/R/library/pathphynder
sed -i "s#^packpwd<-.*\+\$#packpwd<-'$PREFIX/lib/R/library/pathphynder/R'#g" pathPhynder.R
sed -i "s#^packpwd<-.*\+\$#packpwd<-'$PREFIX/lib/R/library/pathphynder/R'#g" $PREFIX/lib/R/library/pathphynder/R/{pileup_and_filter,addAncToTree,chooseBestPath,assign_noNA,functions_pathPhynder,pathPhynder_likelihood_runner}.R
cp pathPhynder.R $PREFIX/bin/pathPhynder
