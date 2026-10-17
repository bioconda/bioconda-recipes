#!/bin/bash

mkdir -p $PREFIX/share/LGVAR

cp LGVAR $PREFIX/share/LGVAR/
chmod +x $PREFIX/share/LGVAR/LGVAR

cp utils.py $PREFIX/share/LGVAR/

cp -r src $PREFIX/share/LGVAR/

if [ -d examples ]; then
    cp -r examples $PREFIX/share/LGVAR/
fi

mkdir -p $PREFIX/bin

cat > $PREFIX/bin/LGVAR << EOF
#!/bin/bash
exec $PREFIX/share/LGVAR/LGVAR "\$@"
EOF

chmod +x $PREFIX/bin/LGVAR