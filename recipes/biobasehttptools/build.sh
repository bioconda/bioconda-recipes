#!/bin/bash
mv AccessionToTaxId ${PREFIX}/bin/AccessionToTaxId
mv ${PREFIX}/bin/AccessionToTaxId ${PREFIX}/bin/AccessionToTaxId-bin
echo -e "#!/bin/bash\nexport SYSTEM_CERTIFICATE_PATH=${PREFIX}/ssl/cacert.pem\n${PREFIX}/bin/AccessionToTaxId-bin \"\$@\"\n" > ${PREFIX}/bin/AccessionToTaxId
chmod 755 ${PREFIX}/bin/AccessionToTaxId
mv ${PREFIX}/bin/FetchSequence ${PREFIX}/bin/FetchSequence-bin
echo -e "#!/bin/bash\nexport SYSTEM_CERTIFICATE_PATH=${PREFIX}/ssl/cacert.pem\n${PREFIX}/bin/FetchSequence-bin \"\$@\"\n" > ${PREFIX}/bin/FetchSequence
chmod 755 ${PREFIX}/bin/FetchSequence
mv ${PREFIX}/bin/GeneIdToGOTerms ${PREFIX}/bin/GeneIdToGOTerms-bin
echo -e "#!/bin/bash\nexport SYSTEM_CERTIFICATE_PATH=${PREFIX}/ssl/cacert.pem\n${PREFIX}/bin/GeneIdToGOTerms-bin \"\$@\"\n" > ${PREFIX}/bin/GeneIdToGOTerms
chmod 755 ${PREFIX}/bin/GeneIdToGOTerms
mv ${PREFIX}/bin/GeneIdToUniProtId ${PREFIX}/bin/GeneIdToUniProtId-bin
echo -e "#!/bin/bash\nexport SYSTEM_CERTIFICATE_PATH=${PREFIX}/ssl/cacert.pem\n${PREFIX}/bin/GeneIdToUniProtId-bin \"\$@\"\n" > ${PREFIX}/bin/GeneIdToUniProtId
chmod 755 ${PREFIX}/bin/GeneIdToUniProtId

