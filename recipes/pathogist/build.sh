cp -R ${SRC_DIR}/pathogist ${PREFIX}/bin
cp ${SRC_DIR}/pathogist.py ${PREFIX}/bin
ln -s ${PREFIX}/bin/pathogist.py ${PREFIX}/bin/PATHOGIST
chmod +x ${PREFIX}/bin/PATHOGIST
