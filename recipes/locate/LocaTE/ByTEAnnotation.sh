#!/bin/bash
a=$(echo ${1})
b=$(echo ${2})
FilterProbability=$(echo ${3})
max_iterations=$(echo ${4})
#
single_tebed=$(readlink -f ${a})
MultiTEReads=$(readlink -f ${b})
CycleTime=1
#
[ -z ${FilterProbability} ] && FilterProbability=0.8
[ -e "SettledReads" ] && rm SettledReads
# EM Iteration
while [ $CycleTime -lt $max_iterations ]; 
do
  echo -n ${CycleTime}
  CycleTime=$(expr ${CycleTime} + 1)

  # Count of each TE annotation in multi-mapped TE reads
  awk -v OFS="\t" '{print$1}' ${MultiTEReads} | sort | uniq -c | awk -v OFS="\t" '{print$2,$1}' > RealMultiCount
  # TE annotations with multi mappers
  awk '{print $1}' RealMultiCount > RealMultiAnnotation

  # TE annotation's ratio in single-mapped TE reads
  ## multi-mapped TE read count
  [ -e "ExpectationCount" ] || MultiTECount=$(awk '{print$3}' ${MultiTEReads} | sort -u | wc -l)
  ## only calculating the ratio with multi mappers
  [ -e "ExpectationCount" ] || awk -v OFS="|" '{print$7,$10,$11,$16,$17,$18}' ${single_tebed} | sort | uniq -c | awk -v OFS="\t" 'BEGIN {  while(getline<"RealMultiAnnotation") a[$1]=1; close("RealMultiAnnotation"); } { if ( a[$2]==1 ) print $0 }' > tmp
  ## proportion of each annotation and expected count
  [ -e "ExpectationCount" ] || awk -v OFS="\t" -v MultiTECount=${MultiTECount} '{ sum += $1; fields[$2] = $1; } END {
    for (name in fields) {
      print name, fields[name]/sum, MultiTECount*fields[name]/sum;  
    }
  }' tmp > ExpectationCount

  # Distributed probability of each TE annotation
  awk -v OFS="\t" 'NR==FNR { k[$1]=$2; next } { if (k[$1]!="") print $1,$3/k[$1]; }' RealMultiCount ExpectationCount > ExpectationProbability
  # Updating the ExpectationProbability excluded the first cycle
  [ -e "SettledReadsTECount" ] && awk -v OFS="\t" 'NR==FNR { k[$1]=$2; next } { if ((k[$1]!="") && ($3-k[$1]>0)) print $1, ($3-k[$1])/$3 }' SettledReadsTECount ExpectationCount > ExpectationProbability

  # Merge the files (MultiTEReads and ExpectationProbability) 
  awk -v OFS="\t" 'NR==FNR { k[$1]=$2; next } { if (k[$1]!="") print $0, k[$1] }' ExpectationProbability ${MultiTEReads} > ExpectationMultiTEReads

  # Normalizing the probability by each multi-mapped TE read
  awk -v OFS="\t" '{ sum[$3] += $4 } END { for (category in sum) print category, sum[category] }' ExpectationMultiTEReads > tmp
  awk -v OFS="\t" 'NR==FNR { k[$1]=$2; next } { print $0, $4/k[$3] }' tmp  ExpectationMultiTEReads > ExpectationMultiTEReads_Normalized

  # Filtering by the normailzed probability
  awk -v OFS="\t" -v FilterProbability=${FilterProbability} '$5>=FilterProbability {print $1,$2,$3}' ExpectationMultiTEReads_Normalized >> SettledReads

  # Resetting the MultiTEReads file for next cycle
  awk -v OFS="\t" 'BEGIN {  while(getline<"SettledReads") a[$3]=1; close("SettledReads"); } { if ( a[$3]!=1 ) print $1,$2,$3; }' ExpectationMultiTEReads_Normalized > ${MultiTEReads}

  # SettledReads TE annotation count
  awk -v OFS="\t" '{print$1}' SettledReads | sort | uniq -c | sort -k1,1nr | awk -v OFS="\t" '{print$2,$1}' > SettledReadsTECount

  # Ending by MultiTEReadsCount targeted probability (no more MultiTEReads reached the threshold)
  CycleSettledReadCount=$(awk -v FilterProbability=${FilterProbability} '$5>=FilterProbability {print $0}' ExpectationMultiTEReads_Normalized | wc -l)
  if [ ${CycleSettledReadCount} -lt 10 ]; then
    break
  fi
done

