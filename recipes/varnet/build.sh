#!/bin/bash
TARGET=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $TARGET
cp -r * $TARGET/

mkdir -p $PREFIX/bin

# Wrapper for predict.py
cat << EOF > $PREFIX/bin/varnet-predict
#!/bin/bash
python $TARGET/predict.py "\$@"
EOF
chmod +x $PREFIX/bin/varnet-predict

# Wrapper for filter.py
cat << EOF > $PREFIX/bin/varnet-filter
#!/bin/bash
python $TARGET/filter.py "\$@"
EOF
chmod +x $PREFIX/bin/varnet-filter
