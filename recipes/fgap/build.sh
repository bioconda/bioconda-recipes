#!/bin/bash
cat > FGAP <<EOF
#!/bin/bash
octave --path "$PREFIX/bin/" --no-gui --eval "fgap \$@"
EOF

chmod +x FGAP
cp fgap.m $PREFIX/bin/
cp FGAP $PREFIX/bin/
