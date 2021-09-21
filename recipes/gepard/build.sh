#!/bin/bash

GEPARD_DIR=${PREFIX}/share/gepard
mkdir -p ${PREFIX}/bin
mkdir -p ${GEPARD_DIR}
cp -r * ${GEPARD_DIR}


cat <<END >>${PREFIX}/bin/gepardcmd
#!/bin/bash

java -cp $GEPARD_DIR/dist/Gepard-2.1.jar org.gepard.client.cmdline.CommandLine
END

cat <<END >>${PREFIX}/bin/gepard
#!/bin/bash

java -jar $GEPARD_DIR/dist/Gepard-2.1.jar
END

chmod +x ${PREFIX}/bin/*
