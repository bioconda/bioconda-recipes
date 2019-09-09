#!/bin/bash
declare -a tools=("AccessionToTaxId" "FetchSequence" "GeneIdToGOTerms" "GeneIdToUniProtId")
for t in "${tools[@]}"
do
   echo "${t}"
   mv $t ${PREFIX}/bin/${t}
   mv ${PREFIX}/bin/${t} ${PREFIX}/bin/${t}-bin
   echo -e "#!/bin/bash\nexport SYSTEM_CERTIFICATE_PATH=${PREFIX}/ssl/cacert.pem\n${PREFIX}/bin/${t}-bin \"\$@\"\n" > ${PREFIX}/bin/${t}
   chmod 755 ${PREFIX}/bin/${t}
done
