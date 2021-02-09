atlasprodDir=${PREFIX}/atlasprod

sed -i.bak "s+<CONDA_PREFIX>+${PREFIX}+g" $atlasprodDir/supporting_files/AtlasSiteConfig.yml
