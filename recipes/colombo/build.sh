#!/usr/bin/env bash
mkdir -p $PREFIX/Colombo
cp -r . $PREFIX/Colombo
mkdir -p $PREFIX/bin
PROGRAM="SigiHMM"; sed "s\`PREFIX\`${PREFIX}\` ; s\`PROGRAM\`${PROGRAM}\`" $RECIPE_DIR/Colombo > $PREFIX/bin/$PROGRAM; chmod +x $PREFIX/Colombo/Colombo/$PROGRAM
PROGRAM="mSigiHMM"; sed "s\`PREFIX\`${PREFIX}\` ; s\`PROGRAM\`${PROGRAM}\`" $RECIPE_DIR/Colombo > $PREFIX/bin/$PROGRAM; chmod +x $PREFIX/Colombo/Colombo/$PROGRAM
PROGRAM="SigiCRF"; sed "s\`PREFIX\`${PREFIX}\` ; s\`PROGRAM\`${PROGRAM}\`" $RECIPE_DIR/Colombo > $PREFIX/bin/$PROGRAM; chmod +x $PREFIX/Colombo/Colombo/$PROGRAM
PROGRAM="Colombo"; sed "s\`PREFIX\`${PREFIX}\` ; s\`PROGRAM\`${PROGRAM}\`" $RECIPE_DIR/Colombo > $PREFIX/bin/$PROGRAM; chmod +x $PREFIX/Colombo/Colombo/$PROGRAM
chmod +x $PREFIX/bin/*