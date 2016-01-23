mkdir -pv ${PREFIX}/bin ${PREFIX}/etc/conda/activate.d ${PREFIX}/etc/conda/deactivate.d
cp -R {*.sh,*.pl,MUMmer3.20,mugsy,mugsyWGA,synchain-mugsy} ${PREFIX}/bin
cp mugsyenv.sh ${PREFIX}/etc/conda/activate.d
cat <<EOF >>  ${PREFIX}/etc/conda/deactivate.d/mugsyenv.sh
unset MUGSY_INSTALL
unset PERL5LIB
EOF
