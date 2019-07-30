mkdir -p $PREFIX/bin
mkdir -p $PREFIX/bin/logs
cp -R * $PREFIX/bin/
cp -R logs/ $PREFIX/bin/
chmod 775 -R $PREFIX/bin/logs
chmod 775 -R $USER $PREFIX/bin/logs
sudo chmod 775 -R $PREFIX/bin/logs
sudo chmod 775 -R $USER $PREFIX/bin/logs

