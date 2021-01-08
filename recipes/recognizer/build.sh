mkdir -p "${PREFIX}/share"
cp recognizer.py "${PREFIX}/share"
cp -r resources/* "${PREFIX}/share"
ln -s "${PREFIX}/share/recognizer.py" "${PREFIX}/bin"