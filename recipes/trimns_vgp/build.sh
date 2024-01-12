#!/bin/bash
cd ./pipeline/bionano/trimNs

echo "#!/bin/env/python" > ${PREFIX}/bin/clip_regions_DNAnexus.py
echo "#!/bin/env/python" > ${PREFIX}/bin/remove_fake_cut_sites_DNAnexus.py
echo "#!/bin/env/python" > ${PREFIX}/bin/trim_Ns_DNAnexus.py


cat ./clip_regions_DNAnexus.py >> ${PREFIX}/bin/clip_regions_DNAnexus.py
cat ./remove_fake_cut_sites_DNAnexus.py >> ${PREFIX}/bin/remove_fake_cut_sites_DNAnexus.py
cat ./trim_Ns_DNAnexus.py >> ${PREFIX}/bin/trim_Ns_DNAnexus.py

chmod +x ${PREFIX}/bin/clip_regions_DNAnexus.py
chmod +x ${PREFIX}/bin/remove_fake_cut_sites_DNAnexus.py
chmod +x ${PREFIX}/bin/trim_Ns_DNAnexus.py