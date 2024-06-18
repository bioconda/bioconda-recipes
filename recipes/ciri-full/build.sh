#!/bin/bash -euo

make

mkdir -p $PREFIX/bin

cp bin/CIRI-Full_v2.1.2.jar $PREFIX/bin/CIRI-full.jar

# Create a wrapper script to run the jar file
# Command is java -jar $PREFIX/bin/CIRI-full.jar
# Use /usr/bin/env java
cat > $PREFIX/bin/CIRI-full <<EOF
#!/bin/bash
/usr/bin/env java -jar $PREFIX/bin/CIRI-full.jar \$@
EOF

chmod a+x $PREFIX/bin/CIRI-full

cp bin/CIRI_v2.0.6/CIRI2.pl $PREFIX/bin/CIRI.pl
ln -s $PREFIX/bin/CIRI.pl $PREFIX/bin/CIRI
chmod a+x $PREFIX/bin/CIRI.pl

cp bin/CIRI_AS_v1.2/CIRI_AS_v1.2.pl $PREFIX/bin/CIRI-AS.pl
ln -s $PREFIX/bin/CIRI-AS.pl $PREFIX/bin/CIRI-AS
chmod a+x $PREFIX/bin/CIRI-AS.pl
