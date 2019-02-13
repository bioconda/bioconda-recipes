mv IBM ${PREFIX} 
mkdir build
cd build
cmake \
-DLIBLEMON_ROOT=${PREFIX} \
-DLIBOGDF_ROOT=${PREFIX}/ogdf \
-DCPLEX_INC_DIR=${PREFIX}/IBM/cplex/include/ \
-DCPLEX_LIB_DIR=${PREFIX}/IBM/cplex/lib/x86-64_linux/static_pic \
-DCONCERT_LIB_DIR=${PREFIX}/IBM/concert/lib/x86-64_linux/static_pic \
-DCONCERT_INC_DIR=${PREFIX}/IBM/concert/include/ ..

make

chmod +x heinz
mv heinz ${PREFIX}/bin