#!/bin/bash

mkdir -p $PREFIX/bin
mv trident-* ${PREFIX}/bin/trident-bin
echo -e "#!/bin/bash\nexport SYSTEM_CERTIFICATE_PATH=${PREFIX}/ssl/cacert.pem\n${PREFIX}/bin/trident-bin \"\$@\"\n" > ${PREFIX}/bin/trident
chmod 755 ${PREFIX}/bin/trident
chmod 755 ${PREFIX}/bin/trident-bin