#!/bin/bash
mkdir -p $PREFIX/share/mnbc-me
cp MNBC_ME.jar $PREFIX/share/mnbc-me/

mkdir -p $PREFIX/bin
cat <<EOF > $PREFIX/bin/mnbc-me
#!/bin/bash

MEM=\${MNBC_ME_MEM:-1G}

exec java -Xmx\${MEM} \${JAVA_OPTS} -cp \$PREFIX/share/mnbc-me/MNBC_ME.jar MNBC_ME "\$@"
EOF

chmod +x $PREFIX/bin/mnbc-me