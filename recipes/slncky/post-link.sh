#!/bin/bash
echo "It is necessary to download annotations. This can take awhile and when expanded uses about 12GB."
echo "Download annotations from https://www.dropbox.com/s/pq7wsjx61sp8ghm/annotations.tar.gz"
echo "That expanded directory, or a soft link to it needs to be placed in:"
echo "$PREFIX/bin"
echo "See http://slncky.github.io/install.html for more info."
# Because of the size of the annotations directory, it is not being automatically uploaded.
# The automated Travis testing used for bioconda passes with the following in OSX,
# but in the linux docker image, it has the error: no space left on device.
# cd $PREFIX/bin
# echo "wget https://www.dropbox.com/s/pq7wsjx61sp8ghm/annotations.tar.gz"
# wget https://www.dropbox.com/s/pq7wsjx61sp8ghm/annotations.tar.gz
# echo "tar -xzvf annotations.tar.gz"
# tar -xzvf annotations.tar.gz
# echo "rm annotations.tar.gz"
# rm annotations.tar.gz
# echo "Finished downloading annotations."
exit 0
