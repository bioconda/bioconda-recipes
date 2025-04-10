#!/bin/bash
outside_cycle_time=$(echo ${1})
current_by=$(echo ${2})
single_te_bed=$(echo ${3})
multi_te_bed=$(echo ${4})
out_record=$(echo ${5})

# record SettledReads  
awk  -v OFS="\t" '{ split($2,a,"|"); print a[1],a[2],a[3],$3 }' SettledReads > tmp
awk -v OFS="\t" 'BEGIN { while(getline<"tmp") a[$1,$2,$3,$4]=1; close("tmp"); } { if ( a[$1,$2,$3,$4]==1 ) print $0 }' ${multi_te_bed} > CurrentRecord
cat CurrentRecord | sed "s/^/${current_by}\t${outside_cycle_time}\t&/g" >> ../SettledReads_log
cat CurrentRecord | awk -v OFS="\t" '{print$7,$10,$11,$16,$17,$18 "\t" $1,$2,$3 "\t" $4 }' >> ${out_record}

# modify the *_te.bed files 
cat CurrentRecord >> ${single_te_bed}
awk -v OFS="\t" 'BEGIN { while(getline<"tmp") a[$4]=1; close("tmp"); } { if ( a[$4]!=1 ) print $0 }' ${multi_te_bed} > tmp2 && mv tmp2 ${multi_te_bed}

# delete other files
ls | grep -vE "*Normalized*|multi_te.bed|single_te.bed" | xargs rm 
