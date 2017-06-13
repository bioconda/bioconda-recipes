#!/bin/bash
#
#$ -cwd
#$ -S /bin/bash
#
set -o nounset -o pipefail -o errexit
set -o xtrace

echo "Running build.sh"

echo $(pwd)
echo $(ls)

cd ./bin/

mkdir ../results/

mkdir ../temp/


sh project.sh ../data/pressto_LUNG_enhancers.bed DEFAULT_EQ DEFAULT_ET

# sudo yum -y install python
# 
# sudo yum -y install python-devel
# 
# sudo yum -y install epel-release
# 
# sudo yum -y install python-pip
# 
# sudo pip install pandas
# 
# sudo yum -y group install "Development Tools"
# 
# sudo yum -y install zlib-devel
# 
# sudo yum -y install BEDTools
# 
# sudo pip install pybedtools
# 
# sudo yum -y install R
# 
# sudo yum -y install curl-devel
# 
# sudo Rscript -e 'install.packages(c("RCurl","gProfileR"), repos="https://cran.rstudio.com")'