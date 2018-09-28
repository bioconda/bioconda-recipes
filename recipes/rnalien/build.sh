#!/bin/bash
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"
export LDFLAGS="-L${PREFIX}/lib"
export CPPFLAGS="-I${PREFIX}/include"

stack setup
stack update
stack install --extra-include-dirs ${PREFIX}/include --local-bin-path ${PREFIX}/bin
mv ${PREFIX}/bin/RNAlien ${PREFIX}/bin/RNAlien-bin
echo -e "#!/bin/bash\nexport SYSTEM_CERTIFICATE_PATH=/usr/local/ssl/cacert.pem\n${PREFIX}/bin/RNAlien-bin \"\$@\"\n" > ${PREFIX}/bin/RNAlien
chmod 755 ${PREFIX}/bin/RNAlien
#cleanup
rm -r .stack-work
