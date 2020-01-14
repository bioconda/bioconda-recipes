echo "PREFIX: ${PREFIX}"
ls
echo "-----"
pwd
echo "-----"
cat build_env_setup.sh
echo "_____"
cat conda_build.sh
echo "_____"

cp -r bin ${PREFIX}/bin
cp -r dependencies ${PREFIX}/dependencies
