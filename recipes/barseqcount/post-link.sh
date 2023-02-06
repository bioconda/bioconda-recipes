#!/bin/sh
echo "#!/bin/sh
python -m barseqcount \$@
" >  "$CONDA_PREFIX"/bin/barseqcount
chmod +x "$CONDA_PREFIX"/bin/barseqcount

