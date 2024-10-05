#!/bin/bash
multi_te_bed=$(echo ${1})

# merge the probability in each section
awk -v OFS="\t" '{ print $1"|"$2"|"$3,$4 }' ${multi_te_bed} > merge_0

## ./ByTESubfamily/ExpectationMultiTEReads_Normalized
if [ -e "../ByTESubfamily" ]; then
    awk -v OFS="\t" '
        NR==FNR { k[$2,$3]=$5; next }
        {  if (k[$1,$2]!="") {print $0,k[$1,$2]} else {print $0,0} }
        ' ../ByTESubfamily/ExpectationMultiTEReads_Normalized merge_0 > merge_1
else
    awk -v OFS="\t" '{print $0, "0"}' merge_0 > merge_1
fi
## ./ByTEConsensus_SubFamily/ExpectationDepthMultiTEReads_Normalized
if [ -e "../ByTEConsensus_SubFamily" ]; then    
    awk -v OFS="\t" '
        NR==FNR { k[$4,$5]=$8; next }
        {  if (k[$1,$2]!="") {print $0,k[$1,$2]} else {print $0,0} }
        ' ../ByTEConsensus_SubFamily/ExpectationDepthMultiTEReads_Normalized merge_1 > merge_2
else
    awk -v OFS="\t" '{print $0, "0"}' merge_1 > merge_2
fi
## ./ByTEAnnotation/ExpectationMultiTEReads_Normalized'
if [ -e "../ByTEAnnotation" ]; then    
    awk -v OFS="\t" '
        NR==FNR { k[$2,$3]=$5; next }
        {  if (k[$1,$2]!="") {print $0,k[$1,$2]} else {print $0,0} }
        ' ../ByTEAnnotation/ExpectationMultiTEReads_Normalized merge_2 > merge_3
else
    awk -v OFS="\t" '{print $0, "0"}' merge_2 > merge_3
fi
## ./ByTEConsensus_Annotation/ExpectationDepthMultiTEReads_Normalized
if [ -e "../ByTEConsensus_Annotation" ]; then    
    awk -v OFS="\t" '
        NR==FNR { k[$4,$5]=$8; next }
        {  if (k[$1,$2]!="") {print $0,k[$1,$2]} else {print $0,0} }
        ' ../ByTEConsensus_Annotation/ExpectationDepthMultiTEReads_Normalized merge_3 > merge_4
else
    awk -v OFS="\t" '{print $0, "0"}' merge_3 > merge_4
fi


# sum probability

awk -v OFS="\t" '{print $1,$2,$3+$4+$5+$6}' merge_4 > merge_sum
# normalization
awk -v OFS="\t" '{ sum[$2] += $3 } END { for (category in sum) print category, sum[category] }' merge_sum > tmp
awk -v OFS="\t" '
NR==FNR { k[$1]=$2; next }
{ if( k[$2] != 0 ) {print $0, $3/k[$2]} else {print $0, 0} }
' tmp  merge_sum > merge_sum_normalization
## recording equal probability reads
awk 'seen[$2,$3]++ {print $2}' merge_sum_normalization > EqualProbabilityReads

# Reserving the lines with maximum joint probability
awk -v OFS="\t" 'BEGIN { while(getline<"EqualProbabilityReads") a[$1]=1; close("EqualProbabilityReads"); } { if (( a[$2]!=1 ) && ($4 > max[$2])) {max[$2]=$4; maxline[$2]=$0}} END { for (category in max) print max[category], maxline[category] }' merge_sum_normalization  > SettledReads
# 
