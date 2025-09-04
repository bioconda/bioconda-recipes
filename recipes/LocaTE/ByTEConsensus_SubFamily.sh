#!/bin/bash
a=$(echo ${1})
b=$(echo ${2})
FilterProbability=$(echo ${3})
max_iterations=$(echo ${4})
#
SingleTEReads_bed=$(readlink -f ${a})
MultiTEReads_bed=$(readlink -f ${b})
CycleTime=1
# parameter
CycleTime=1
# cycle
[ -e "SettledReads" ] && rm SettledReads
[ -e "SettledReadsTEconsensue" ] && rm SettledReadsTEconsensue 
while [ $CycleTime -lt $max_iterations ]; 
do
  # echo -n "$CycleTime"
  CycleTime=$(expr ${CycleTime} + 1)
  # Expressed TE consensue in MultiTEReads 
  awk -v OFS="\t" '{ split($4,a,"|"); 
    if ( $2>=a[2]) {
      start=a[5]+$2-a[2]
    } else {
      start=a[5]
    }
    if ( $3<a[3] ) {
      end=a[6]-a[3]+$3
    } else {
      end=a[6] 
    }
    if ( end>start && start>0 && end>0 ) { 
      print $4, start, end, $1"|"$2"|"$3, $5
    } else if ( start>end && start>0 && end>0  ) { 
      print $4, end, start, $1"|"$2"|"$3, $5 }
  }' ${MultiTEReads_bed} | sort -k1,1 -k2,2n > MultiTEconsensue_b
  # TE annotation 
  awk -v OFS="\t" '{ split($4,a,"|"); print $4, a[5], a[6] }' ${MultiTEReads_bed} | sort -u > MultiTEconsensue_a
  # statisticing all subfamily instead of specific TE annotaiton
  ## only reserve the TE consensus of maximum length
  awk -v OFS="\t" '{ split($1,a,"|"); print a[4],"1",$3 }' MultiTEconsensue_a | sort -k3,3nr | awk '!seen[$1]++' > tmp && mv tmp MultiTEconsensue_a
  ## expressed base positions
  awk -v OFS="\t" '{ split($1,a,"|"); print a[4],$2,$3,$4,$5 }' MultiTEconsensue_b > tmp && mv tmp MultiTEconsensue_b
  ## Coverage & Depth of MultiTEReads in TEConsensus
  bedtools coverage -d -a MultiTEconsensue_a -b MultiTEconsensue_b | awk -v OFS="\t" '{print $1"|"$4, $1, $5}' > MultiTEconsensue_coverage

  # Expressed TE consensue in SingleTEReads
  if [ -e "SettledReadsTEconsensue" ] ; then
    cat SettledReadsTEconsensue >> SingleTEconsensue_b
    sort -k1,1 -k2,2n SingleTEconsensue_b > tmp && mv tmp SingleTEconsensue_b
  else
    awk -v OFS="\t" '{split($4,a,"|"); 
    if ( $2>=a[2]) {
      start=a[5]+$2-a[2]
    } else {
      start=a[5]
    }
    if ( $3<a[3] ) {
      end=a[6]-a[3]+$3
    } else {
      end=a[6] 
    }
    if ( end>start && start>0 && end>0 ) { print a[4], start, end }
    else if ( start>end && start>0 && end>0  ) { print a[4], end, start }
    }' ${SingleTEReads_bed} > tmp
    # only select the TE consensus with multi-mapper
    awk 'BEGIN {  while(getline<"MultiTEconsensue_a") a[$1]=1; close("MultiTEconsensue_a"); } { if ( a[$1]==1 ) print $0; }' tmp | sort -k1,1 -k2,2n > SingleTEconsensue_b 
  fi
  # Coverage & Depth of SinglTEReads in the relative TEConsensus
  bedtools coverage -d -a MultiTEconsensue_a -b SingleTEconsensue_b | awk -v OFS="\t" '{print $1"|"$4, $1, $5}' > SingleTEconsensue_coverage

  # SingleTEReads probability in base level of each TE annoatation
  awk -v OFS="\t" '{ sum[$2] += $3} END { for (category in sum) print category, sum[category] }' SingleTEconsensue_coverage > SingleTEconsensue_length
  awk -v OFS="\t" '
  NR==FNR { k[$1]=$2; next }
    # { print $0,k[$2]; } 
    { if(k[$2]!=0) print $0, $3/k[$2]; } 
  ' SingleTEconsensue_length SingleTEconsensue_coverage > SingleTEconsensue_coverageRatio

  # Total length of each TE annoatation in MultiTEReads
  awk -v OFS="\t" '{ sum[$2] += $3} END { for (category in sum) print category, sum[category] }' MultiTEconsensue_coverage > MultiTEconsensue_length
  # ExpectationDepth in each base 
  awk -v OFS="\t" '
  NR==FNR { k[$1]=$2; next }
      # { print $0, k[$2]; } 
      { print $1, k[$2]*$4; } 
      ' MultiTEconsensue_length SingleTEconsensue_coverageRatio > ExpectationDepth

  # Calculating the probability by merging the ExpectationDepth and MultiTEconsensue_coverage 
  awk -v OFS="\t" '
  NR==FNR { k[$1]=$2; next }
      { if($3!=0) { print $1, $2, $3, k[$1], k[$1]/$3 }
      else { print $1, $2, $3, k[$1], 0 } }
      ' ExpectationDepth MultiTEconsensue_coverage > ExpectationDepthProbability

  # Expectation Depth of MultiTEReads in each base
  ## tmp_a 
  awk -v OFS="\t" '!seen[$4]++' MultiTEconsensue_b > tmp_a
  ## tmp_b (clean the tab in last column)
  awk  -v OFS="\t" '{ split($1,a,/\|/); print $2,a[2],a[2]+1,$5; }' ExpectationDepthProbability > tmp_b
  ## definite integration by (intersect + awk) 
  bedtools intersect -wb -wb -a tmp_a -b tmp_b | awk '{ sum[$4] += $8} END { for (category in sum) print category, sum[category] }' > tmp_SumProbability
  ## merge 
  awk -v OFS="\t" '
  NR==FNR { k[$1]=$2; next }
      { print $0, k[$4] }
      ' tmp_SumProbability MultiTEconsensue_b > ExpectationDepthMultiTEReads

  # Normalization
  awk -v OFS="\t" '{ sum[$5] += $6 } END { for (category in sum) print category, sum[category] }' ExpectationDepthMultiTEReads > tmp
  awk -v OFS="\t" '
  NR==FNR { k[$1]=$2; next }
    {if ( k[$5]!=0 ) print $0, k[$5], $6/k[$5] }
  ' tmp  ExpectationDepthMultiTEReads > ExpectationDepthMultiTEReads_Normalized

  # Filtering by the normailzed probability
  awk -v OFS="\t" -v FilterProbability=${FilterProbability} '$8>=FilterProbability {print $1,$4,$5}' ExpectationDepthMultiTEReads_Normalized >> SettledReads

  # SettledReads to BED to Depth
  awk '{ print $3 }' SettledReads > SettledReadsName
  # source the TE annotation of SettledReads
  awk -v OFS="\t" 'BEGIN {  while(getline<"SettledReadsName") a[$1]=1; close("SettledReadsName"); } { if ( a[$5]==1 && !seen[$5]++ ) print $0; }' ${MultiTEReads_bed} > tmp
  awk -v OFS="\t" '{ split($4,a,"|"); 
    if ( $2>=a[2]) {
      start=a[5]+$2-a[2]
    } else {
      start=a[5]
    }
    if ( $3<a[3] ) {
      end=a[6]-a[3]+$3
    } else {
      end=a[6] 
    }
    if ( end>start && start>0 && end>0 ) { print a[4], start, end }
    else if ( start>end && start>0 && end>0  ) { print a[4], end, start }
  }' tmp > SettledReadsTEconsensue

  # Resetting the MultiTEReads file for next cycle
  awk -v OFS="\t" 'BEGIN {  while(getline<"SettledReads") a[$3]=1; close("SettledReads"); } { if ( a[$5]!=1 ) print $0; }' ${MultiTEReads_bed} > tmp && mv tmp ${MultiTEReads_bed}

  # Ending by MultiTEReadsCount targeted probability (no more MultiTEReads reached the threshold)
  CycleSettledReadCount=$(awk -v FilterProbability=${FilterProbability} '$8>=FilterProbability {print $0}' ExpectationDepthMultiTEReads_Normalized | wc -l)
  if [ ${CycleSettledReadCount} -lt 10 ]; then
    break
  fi

done


