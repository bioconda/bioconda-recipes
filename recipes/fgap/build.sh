#!/bin/bash
echo "#!/bin/bash" >> FGAP
ls
echo "echo 'starting FGAP'" >> FGAP
echo "octave --path \"$PREFIX/bin/\" --no-gui --eval \"fgap \$@\"" >> FGAP
chmod +x FGAP
cp fgap.m $PREFIX/bin/
cp FGAP $PREFIX/bin/
