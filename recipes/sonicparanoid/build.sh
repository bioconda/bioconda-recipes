echo Building module for ortholog groups inference...
# enter the source directory
cd ./sonicparanoid/quick_multi_paranoid/
# build the modules
make qa
# go back to root
cd ../../
pwd
# install sonicparanoid
echo Building sonicparanoid...
python setup.py install --single-version-externally-managed --record=record.txt  # Python command to install the script.
