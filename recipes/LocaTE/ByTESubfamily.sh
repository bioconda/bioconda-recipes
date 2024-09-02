#!/bin/bash
single_te_bed=$(echo ${1})
MultiTEReads=$(echo ${2})
FilterProbability=$(echo ${3})
max_iterations=$(echo ${4})
CycleTime=1
#
[ -e "SettledReads" ] && rm SettledReads
while [ $CycleTime -lt $max_iterations ]; 
do
    # echo -n ${CycleTime}
    CycleTime=$(expr ${CycleTime} + 1)
    # ExpectationCount
    [ -e "ExpectationCount" ] || MultiTECount=$(awk '{print$3}' ${MultiTEReads} | sort -u | wc -l)
    [ -e "ExpectationCount" ] || awk '$8!="." {print$16}' ${single_te_bed} | sort | uniq -c | awk -v OFS="\t" -v MultiTECount=${MultiTECount} '{ sum += $1; fields[$2] = $1; } END {
    for (name in fields) {
        print name,fields[name]/sum,MultiTECount*fields[name]/sum ;  # 打印行名和占比
    }
    }' > ExpectationCount
    
    # subfamily 在多读 reads 中实际分布量
    awk '{print$1}' MultiTEReads | sort | uniq -c | awk -v OFS="\t" '{print$2,$1}' > RealMultiCount

    # expected probability
    awk -v OFS="\t" '
    NR==FNR { k[$1]=$2; next }
    #   { if (k[$1]!="") print $0,k[$1]; }
    { if (k[$1]!=0) print $1,$3/k[$1]; }
    ' RealMultiCount ExpectationCount > ExpectationProbability
    ## in cycle
    [ -e "SettledReadsTECount" ] && awk -v OFS="\t" '
    NR==FNR { k[$1]=$2; next }
        { if ((k[$1]!="") && ($3-k[$1]>0)) print $1, ($3-k[$1])/$3 }
    ' SettledReadsTECount ExpectationCount > ExpectationProbability

    # merge
    awk -v OFS="\t" '
    NR==FNR { k[$1]=$2; next }
    { print $0, k[$1]}
    ' ExpectationProbability MultiTEReads > ExpectationMultiTEReads

    # normalization
    awk -v OFS="\t" '{ sum[$3] += $4 } END { for (category in sum) print category, sum[category] }' ExpectationMultiTEReads > tmp
    awk -v OFS="\t" '
    NR==FNR { k[$1]=$2; next }
    { if( k[$3] != 0 ) print $0, $4/k[$3] }
    ' tmp  ExpectationMultiTEReads > ExpectationMultiTEReads_Normalized

    # Filtering by the normailzed probability
    awk -v OFS="\t" -v FilterProbability=${FilterProbability} '$5>=FilterProbability {print $1,$2,$3}' ExpectationMultiTEReads_Normalized >> SettledReads

    # Resetting the MultiTEReads file for next cycle
    awk -v OFS="\t" 'BEGIN {  while(getline<"SettledReads") a[$3]=1; close("SettledReads"); } { if ( a[$3]!=1 ) print $1,$2,$3; }' ExpectationMultiTEReads_Normalized > MultiTEReads

    # SettledReads TE annotation count
    awk -v OFS="\t" '{print $1}' SettledReads | sort | uniq -c | sort -k1,1nr | awk -v OFS="\t" '{print$2,$1}' > SettledReadsTECount

    # ending
    CycleSettledReadCount=$(awk -v FilterProbability=${FilterProbability} '$5>=FilterProbability {print $0}' ExpectationMultiTEReads_Normalized | wc -l)
    if [ ${CycleSettledReadCount} -lt 10 ]; then
        break
    fi
done
