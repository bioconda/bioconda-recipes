mkdir -p "$PREFIX"/opt/pepnet/
mkdir -p "$PREFIX"/bin

dos2unix denovo.py utils.py
cp denovo.py utils.py "$PREFIX"/opt/pepnet/
ln -s "$PREFIX"/opt/pepnet/denovo.py "$PREFIX"/bin/denovo.py
