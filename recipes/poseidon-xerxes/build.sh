#!/bin/bash

mkdir -p $PREFIX/bin
mv xerxes-* ${PREFIX}/bin/xerxes-bin
echo -e "#!/bin/bash\nexport SYSTEM_CERTIFICATE_PATH=${PREFIX}/ssl/cacert.pem\n${PREFIX}/bin/xerxes-bin \"\$@\"\n" > ${PREFIX}/bin/xerxes
chmod 755 ${PREFIX}/bin/xerxes
chmod 755 ${PREFIX}/bin/xerxes-bin