#!/bin/bash

export LAGRANTO=$PWD
mkdir -p $PREFIX/bin

export NETCDF_LIB=`nf-config --flibs`
export NETCDF_INC=`nf-config --fflags`
export FORTRAN=gfortran

cd $LAGRANTO/lib

\cp ioinp_cdo.f ioinp.f
for lib in iotra ioinp inter times libcdfio libcdfplus; do
  ${FORTRAN} -c -O ${NETCDF_INC} ${lib}.f
  ar r ${lib}.a ${lib}.o
  \rm -f ${lib}.l ${lib}.o ${lib}.f
  ranlib ${lib}.a
done


for prog in create_startf caltra trace select density lidar; do
  cd $LAGRANTO/$prog
  make -f ${prog}.make
  sed -i 's,\#\!\/bin\/csh,\#\!\/bin\/csh\nsetenv LAGRANTO '"${PREFIX}"'\/bin\/lagranto_prog,' "${prog}.sh"
  mkdir -p $PREFIX/bin/lagranto_prog/${prog} 
  cp ${prog}.sh $PREFIX/bin/${prog}.ecmwf
  cp ${prog}.sh $PREFIX/bin/${prog}.sh
  cp ${prog}.sh $PREFIX/bin/${prog}
  cp ${prog} $PREFIX/bin/lagranto_prog/${prog}/.
done
ln -s $PREFIX/bin/lagranto_prog/create_startf $PREFIX/bin/lagranto_prog/startf
cp $LAGRANTO/create_startf/create_startf.perl $PREFIX/bin/lagranto_prog/startf/.

cd $LAGRANTO/goodies
for tool in traj2num lsl2rdf changet extract getmima gettidiff getvars list2lsl lsl2list mergetra newtime reformat timeres trainfo difference datelist tracal; do
  if [ -f ${tool}.make ] ; then
     make -f ${tool}.make
  else
     ./${tool}.install
  fi
  sed -i 's,\#\!\/bin\/csh,\#\!\/bin\/csh\nsetenv LAGRANTO '"${PREFIX}"'\/bin\/lagranto_prog,' "${tool}.sh"
  cp ${tool}.sh $PREFIX/bin/${tool}.sh
  cp ${tool}.sh $PREFIX/bin/${tool}.ecmwf
  cp ${tool}.sh $PREFIX/bin/${tool}
  mkdir -p $PREFIX/bin/lagranto_prog/goodies
  cp $LAGRANTO/goodies/${tool} $PREFIX/bin/lagranto_prog/goodies/.
  cp $LAGRANTO/goodies/${tool}.sh $PREFIX/bin/lagranto_prog/goodies/.
#  mv $[tool} $PREFIX/bin/goodies/${tool}
done

sed -i 's,\#\!\/bin\/csh,\#\!\/bin\/csh\nsetenv LAGRANTO '"${PREFIX}"'\/bin\/lagranto_prog,' "${LAGRANTO}/bin/lagranto"
sed -i 's,\#\!\/bin\/csh,\#\!\/bin\/csh\nsetenv LAGRANTO '"${PREFIX}"'\/bin\/lagranto_prog,' "${LAGRANTO}/bin/lagrantohelp"
cp $LAGRANTO/bin/lagranto $PREFIX/bin/lagranto.ecmwf
cp $LAGRANTO/bin/lagrantohelp $PREFIX/bin/lagrantohelp.ecmwf
cp $LAGRANTO/bin/lagranto $PREFIX/bin/lagranto
cp $LAGRANTO/bin/lagrantohelp $PREFIX/bin/lagrantohelp
mkdir -p $PREFIX/bin/lagranto_prog/bin
cp $LAGRANTO/bin/lagranto $PREFIX/bin/lagranto_prog/bin/lagranto
cp $LAGRANTO/bin/lagrantohelp $PREFIX/bin/lagranto_prog/bin/lagrantohelp

