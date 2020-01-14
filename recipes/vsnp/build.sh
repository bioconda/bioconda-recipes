echo "PREFIX: ${PREFIX}"
ls
echo "-----"
cat conda_build.sh
echo "_____"

cp -r bin ${PREFIX}/bin
cp -r dependencies ${PREFIX}/dependencies
