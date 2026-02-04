#!/bin/bash
declare -a tools=("AccessionToTaxId" "FetchSequence" "GeneIdToGOTerms" "GeneIdToUniProtId")

mkdir -p $PREFIX/bin
for t in "${tools[@]}"
do
   mv $t ${PREFIX}/bin/${t}-bin
   echo -e "#!/bin/bash\nexport SYSTEM_CERTIFICATE_PATH=${PREFIX}/ssl/cacert.pem\n${PREFIX}/bin/${t}-bin \"\$@\"\n" > ${PREFIX}/bin/${t}
   chmod 755 ${PREFIX}/bin/${t}
done
