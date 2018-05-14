mkdir build
cd build
cmake \
-DLIBLEMON_ROOT=${PREFIX} \
-DLIBOGDF_ROOT=${PREFIX}/ogdf \
-DCPLEX_INC_DIR=../IBM/cplex/include/ \
-DCPLEX_LIB_DIR=../IBM/cplex/lib/x86-64_linux/static_pic \
-DCONCERT_LIB_DIR=../IBM/concert/lib/x86-64_linux/static_pic \
-DCONCERT_INC_DIR=../IBM/concert/include/ ..

chmod +x heinz
mv heinz ${PREFIX}/bin