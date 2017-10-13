#!/bin/bash
echo "Uploading annotations. This can take awhile and when expanded uses about 12GB."
echo "cd $PREFIX"
cd $PREFIX
echo "wget https://www.dropbox.com/s/pq7wsjx61sp8ghm/annotations.tar.gz"
wget https://www.dropbox.com/s/pq7wsjx61sp8ghm/annotations.tar.gz
echo "tar -xzvf annotations.tar.gz"
tar -xzvf annotations.tar.gz
echo "rm annotations.tar.gz"
rm annotations.tar.gz
echo "Finished uploading annotations."
exit 0
