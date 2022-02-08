#!/bin/bash

cd $PREFIX
mv $SRC_DIR $PREFIX/NGSCheckMate

mkdir -p $PREFIX/bin
cat << EOF > $PREFIX/bin/ncm.py
#!/usr/bin/env bash

python $PREFIX/NGSCheckMate/ncm.py "\$@"
EOF

cat << EOF > $PREFIX/bin/ncm_fastq.py
#!/usr/bin/env bash

python $PREFIX/NGSCheckMate/ncm_fastq.py "\$@"
EOF

mkdir -p $PREFIX/etc/conda/activate.d
cat << EOF > $PREFIX/etc/conda/activate.d/activate.sh
#!/usr/bin/env bash

NCM_HOME=$PREFIX/NGSCheckMate
EOF

mkdir -p $PREFIX/etc/conda/deactivate.d
cat << EOF > $PREFIX/etc/conda/deactivate.d/deactivate.sh
#!/usr/bin/env bash

NCM_HOME=
EOF
