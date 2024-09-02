#!/bin/bash
FilterProbability=$(echo ${1})
CycleTime=1
max_iterations=10
#
[ -e "SettledReads" ] && rm SettledReads
while [ $CycleTime -lt $max_iterations ]; 
do
    echo ${CycleTime}
    CycleTime=$(expr ${CycleTime} + 1)
    # ExpectationCount
    [ -e "ExpectationCount" ] || MultiTECount=$(awk '{print$4}' MultiTEReadsXTranscript | sort -u | wc -l)
    [ -e "ExpectationCount" ] || awk -v OFS="\t" '{  fields[$6] = $7; } END {
    for (name in fields) {
        print name,fields[name] ;  # 打印行名和占比
        } 
    }' MultiTEReadsXTranscript > tmp
    ## additional 归一化处理 (not all transcripts are inserted with TE)
    [ -e "ExpectationCount" ] || awk -v OFS="\t" -v MultiTECount=${MultiTECount} '{ sum += $2; fields[$1] = $2; } END {  for (name in fields) {
        print name, fields[name]/sum, MultiTECount*fields[name]/sum ;  # 打印行名和占比
        }
    }' tmp > ExpectationCount
    
    # transcript 在多读 reads 中的实际 count
    awk '{print$6}' MultiTEReadsXTranscript | sort | uniq -c | awk -v OFS="\t" '{print$2,$1}' > RealMultiCount

    # merging RealMultiCount & ExpectationCount 2 expected probability
    awk -v OFS="\t" '
    NR==FNR { k[$1]=$2; next }
    { if (k[$1]!=0) print $1,$3/k[$1]; }
    ' RealMultiCount ExpectationCount > ExpectationProbability
    ## in cycle
    [ -e "SettledReadsTETranscriptCount" ] && awk -v OFS="\t" '
    NR==FNR { k[$1]=$2; next }
        { if ((k[$1]!="") && ($3-k[$1]>0)) print $1, ($3-k[$1])/$3 }
    ' SettledReadsTETranscriptCount ExpectationCount > ExpectationProbability

    # merge
    awk -v OFS="\t" '
    NR==FNR { k[$1]=$2; next }
    { print $0, k[$6]}
    ' ExpectationProbability MultiTEReadsXTranscript > ExpectationMultiTEReads

    # Normalization
    awk -v OFS="\t" '{ sum[$4] += $7 } END { for (category in sum) print category, sum[category] }' ExpectationMultiTEReads > tmp
    awk -v OFS="\t" '
    NR==FNR { k[$1]=$2; next }
    { if( k[$4] != 0 ) print $0, $7/k[$4] }
    ' tmp  ExpectationMultiTEReads > ExpectationMultiTEReads_Normalized

    # Filtering by the normailzed probability
    awk -v OFS="\t" -v FilterProbability=${FilterProbability} '$8>FilterProbability {print $1,$2,$3,$4,$5,$6}' ExpectationMultiTEReads_Normalized >> SettledReads

    # Resetting the MultiTEReads file for next cycle
    awk -v OFS="\t" 'BEGIN { while(getline<"SettledReads") a[$4]=1; close("SettledReads"); } { if ( a[$4]!=1 ) print $1,$2,$3,$4,$5,$6 }' ExpectationMultiTEReads_Normalized > MultiTEReadsXTranscript

    # SettledReads TE-related transcript count
    awk -v OFS="\t" '{print $6}' SettledReads | sort | uniq -c | sort -k1,1nr | awk -v OFS="\t" '{print$2,$1}' > SettledReadsTETranscriptCount

    # ending
    CycleSettledReadCount=$(awk -v FilterProbability=${FilterProbability} '$8>FilterProbability {print $0}' ExpectationMultiTEReads_Normalized | wc -l)
    if [ ${CycleSettledReadCount} -lt 10 ]; then
        break
    fi
done
