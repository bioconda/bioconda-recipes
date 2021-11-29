#!/usr/bin/env python
# coding: utf-8

## python 3.7.7, pandas 1.1.3, numpy 1.19.2
#
# In[1]:
import numpy as np
import pandas as pd
import os
import re
import sys
import argparse
import warnings
warnings.filterwarnings('ignore') ## want to avoid print warnings with pandas merges that can be ignored

parser = argparse.ArgumentParser()


# In[2]:
##### user arguments
parser.add_argument('--version', action='version', version='1.0 (initial release)')

parser.add_argument('--fargene', help='full path to fARGene output, if included')
parser.add_argument('--shortbred', help='full path to shortBRED output (tsv), if included')
parser.add_argument('--shortbred_map', help='full path to shortBRED mapping file, if included and not using default')
parser.add_argument('--abx_map', help='full path to Abx:drug class mapping file, if included')
parser.add_argument('--db_files', help='Path to ontology index files, exclude "/" on end of path ', default= "./db_files")
parser.add_argument('--AMR_key', help='full path to key with known AMR phenotypes, REQUIRED', required = True)
parser.add_argument('--name', help='an identifier for this analysis run, REQUIRED', required = True)
parser.add_argument('--ham_out', help='output file from hAMRonization (tsv), REQUIRED', required = True)

## pull args
args = parser.parse_args()



##Emily's Point To Files for Github
## read in card ontologies as new key
card_key = pd.read_csv(f"{args.db_files}/aro_categories_index.tsv", sep='\t')

## read in drug class key data
if args.abx_map:
    abx_key_name = args.AMR_key
    abx_key = pd.read_csv(abx_key_name)
else:
    abx_key = pd.read_csv(f"{args.db_files}/cleaned_drug_class_key.csv")

# point to known data
if args.AMR_key:
    mock_name = args.AMR_key
    mock = pd.read_csv(mock_name)
    
# point to observed data, e.g. hAMRonization output 
raw_name = args.ham_out 
raw_ham = pd.read_csv(raw_name, error_bad_lines=False, sep = "\t")

## get ham sum and add fargene and shortbred
#resx = ["res_5x/", "res_50x/", "res_100x/"]
this_run_res = args.name
res_name =  args.name
outdir = str(args.name) + "/"
dir_cmd = "mkdir " + outdir
os.system(dir_cmd)

## read in shortbred
if args.shortbred:
    shortbred_path = args.shortbred
    shortbred = pd.read_csv(shortbred_path, sep = "\t")
    ## hits only greater than zero
    shortbred = shortbred[shortbred['Hits'] > 0]
    shortbred['analysis_software_name'] = "shortbred"
    shortbred['gene_symbol'] = shortbred['Family'] ## merge "family" with gene symbol as closest match

    ## give meaning to shortbred family 
    if args.shortbred_map:
        shortmap_name = args.shortbred_map
        shortmap = pd.csv_csv(shortmap_name, sep = "\t")
    else:
        shortmap =pd.read_csv(f'{args.db_files}/ShortBRED_ABR_Metadata.tab', sep = "\t")
    shortbred = shortbred.merge(shortmap, how = "left")
    shortbred['drug_class'] = shortbred['Merged.ID']

    ## merge shortbred and rawham results
    raw_ham = raw_ham.append(shortbred,ignore_index = True)

### integrate fargene results
# note there there is a discrepancy in that the results folder has mixed caps and lower case
# so run "find . -depth | xargs -n 1 rename 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \;" in the command line to fix it
beta_lactam_models = ['class_a', 'class_b_1_2', 'class_b_3', 'class_c', 'class_d_1', 'class_d_2' ]
subdirs = ['class_a', 'class_b_1_2', 'class_b_3', 'class_c', 'class_d_1', 'class_d_2', 'qnr', 'tet_efflux', 'tet_rpg', 'tet_enzyme']

if args.fargene:
    for model in subdirs:
        #for res in resx:
        path = args.fargene #"/home/ewissel/amr-benchmarking/mock_2/" + res + "fargene_out_fa_2/" + model + "/hmmsearchresults/contigs-" + model + "-hmmsearched.out"
            #print(path)
        f = pd.read_csv(fpath, engine='python', sep = "\t", header = 1, skipfooter = 9)
            ## filter to just what this iteration is
            #if res == this_run_res:
        repi = len(f)
        #print(res, "\t", model, "\t", len(f))
        if model in beta_lactam_models:
            resistance = "BETA-LACTAM"
        elif "tet" in model:
            resistance = "tetracycline"
        elif model =="qnr":
            resistance = "QUINOLONE"
        #print("fARGene\t", resistance)

        df = pd.DataFrame({'analysis_software_name': 'fARGene', 'drug_class':[resistance]})  

        newdf = pd.DataFrame(np.repeat(df.values,repi,axis=0))
        newdf.columns = df.columns
               # print(newdf)
        raw_ham = raw_ham.append(newdf,ignore_index = True)
    ##############################
    ## now fargene and shortbred have been added to the raw_ham table


# This was initially a manual cleaning process, but after pouring through the results at one resolution (20x), here is the closest code version of the manual cleaning process. Basically, we want to default to CARD drug classes for accession number. Then, give all the genes with the same gene name the CARD drug class (overriding the HAM drug class). Fill in NAs with the HAM drug class.

## read in above
card_key['AMR Gene Family'] = card_key['AMR Gene Family'].str.lower()
## have top fill in protein accession NAs with 0.00 so that join works
card_key['Protein Accession'] = card_key['Protein Accession'].fillna(101010)
card_key.head()

card = card_key.melt(id_vars=['AMR Gene Family', 'Drug Class', 'Resistance Mechanism'],
             value_vars=['Protein Accession', 'DNA Accession'],
             var_name = "accession_source",
             value_name = "accession")

card['drug_class_card'] = card['Drug Class']

## merge raw ham and card on accession / reference_accession
salted_ham = raw_ham.merge(card, left_on = "reference_accession", right_on = "accession", how = "left")

## if gene_sumbol and drug class card NaN, filter out
smol_gene = salted_ham[['gene_symbol','drug_class_card']].drop_duplicates().dropna(thresh=2)
smol_dict = pd.Series(smol_gene.drug_class_card.values, index=smol_gene.gene_symbol).to_dict()


# In[1385]:
## make def to apply dict to fill in NAs
def curedThatHam(x):
    var = ''
    if pd.isnull(x['drug_class_card']): ## if there is no card match from accession
        gene = x['gene_symbol'] 
        try:
            var = smol_dict[gene]
        except KeyError:
            var = x['drug_class_card']
            
    return var

# apply
salted_ham['drug_class_card'] = salted_ham.apply(lambda x: curedThatHam(x),axis = 1) ## override OG col because check confirmed it was ok

salted_ham.analysis_software_name.unique()
salted_ham['drug_class_ham'] = salted_ham['drug_class']
## There are 9 tools in out salted ham. This is correct. We can now covert salted ham to cured ham
cured_ham = pd.DataFrame(salted_ham)

## import the Resfinder results 
##### this code block is outdated because I did this with the hamronizer tool; leaving for future ref tho
## had to run on web bc the docker version was broke AF

#resfinder_results = pd.read_csv("../mock_2/resfinder/new_resfinder_webpage_results/resfinder_out.tsv", sep = "\t")
#resfinder_results['analysis_software_name'] = "resfinder4_online"

#cured_ham = cured_ham.append(resfinder_results, ignore_index= True) 

### for each row
### if drug_class_card is not empty take value
## elif drug_class_card is empty and drug_class_ham is not empty, take drug_class_ham
## else: (if both columns for drug class are empty) add to counter as lost rows


def simplify_drug_class(dat):
    
    drug_class = ""
    
    if not pd.isna(dat.drug_class_card):
        drug_class = str(dat['drug_class_card'])
    elif not pd.isna(dat.drug_class_ham):
        drug_class = str( dat['drug_class_ham'])
    elif not pd.isna(dat['Drug Class']):
        drug_class = dat['Drug Class'] # from shortbred
    else:
        drug_class = str("unknown")
        
    dat['drug_class'] = drug_class
        
    return dat

import re
cured_ham = cured_ham.apply(lambda x: simplify_drug_class(x), axis = 1)
cured_ham['drug_class'] = cured_ham['drug_class'].str.lower()
cured_ham['drug_class'] = cured_ham['drug_class'].apply(lambda x: (re.split(r";|, |: | and ", x )))

####### has the generic abx names to drug class
abx_key['abx_class'] = (abx_key['drug_class']
     .apply(lambda x: x if type(x)== str else "")
     .apply(lambda x: ''.join(e for e in x if e.isalnum())))


abx_melted = abx_key.melt(value_vars=['Generic name', 'Brand names'], id_vars=['abx_class'], var_name = "abx_type", value_name = "abx")
## currently this is only adding generic names column 
#abx_melted[abx_melted['abx_type']=="Brand names"]


# In[1392]:


abx_melted['abx'] = abx_melted['abx'].str.lower().str.strip()
#abx_melted[abx_melted['abx']=='tazobactam']
## next combine the drug clas to the antibiotic in the mock community

mock['Abx_split'] = mock['Abx'].apply(lambda x: x.split('-') if "-" in x else x)
mock['Abx'] = (mock['Abx'] 
     .apply(lambda x: x if type(x)== str else "")
     .apply(lambda x: ''.join(e for e in x if e.isalnum())))

mock = mock.explode('Abx_split') 
mock['Abx_split'] = mock['Abx_split'].str.lower()

merged = mock.merge(abx_melted, left_on = 'Abx_split', right_on='abx', how='left')
merged['abx_class'] = merged['abx_class'].str.lower()

merged['Abx_split'][merged['abx_class'].isna()].unique() ## need to go make data tidy for this to work sucessfully


# Now we have clean data! Now we want to create true +/- and false +/- in `cured_ham`. 
## first filter merged so it is only the resistant ones
resistant_mock = merged[merged['classification']=="resistant"]
len(resistant_mock['abx'].unique()) # number if resustant antibiotuics
len(resistant_mock['abx_class'].unique()) # number drug classes resistant

sus_mock = merged[merged['classification']=="susceptible"]
boolean_list = ~sus_mock.Abx.isin(resistant_mock['Abx'])
filtered_sus = sus_mock[boolean_list]
filtered_sus.abx.unique() ## only 6 antibiotics that are susceptible in the entire mock community
filtered_sus.abx_class.unique()

## filter filtered sus so that drug classes are unique to sus, not in resistant group
## prior had to filter by antibiotic tested bc only know at drug level, not drug class. 
boolean2 = ~filtered_sus.abx_class.isin(resistant_mock['abx_class'])
smol_sus = filtered_sus[boolean2]
smol_sus.abx_class.unique() ## only 2 drug classes are KNOWN negatives in entire mock 

cured_ham = pd.DataFrame( cured_ham.explode('drug_class'))
cured_ham['drug_class'] = (cured_ham['drug_class']
     .apply(lambda x: x if type(x)== str else "")
     .apply(lambda x: ''.join(e for e in x if e.isalnum())))

#cured_ham['drug_class'].unique()
#cured_ham.head()
#cured_ham.shape ## jumps to over 2000 long


# Now we have the `cured_ham` dataset, which contains all our observations and is cleaned so that every gene observation has a drug class assigned to it (unless the drug class is unknown). 
# Now we want to assign those true/false -/+ values.

# In[1400]:
## give false + / - values
ref_abx = resistant_mock['abx_class'].str.lower()
ref_sus_abx = smol_sus['abx_class'].str.lower()
ref_abx_df = resistant_mock

def get_posneg(row):

    if row['drug_class'] in ref_abx:
        return "true_positive"
    elif row['drug_class'] in resistant_mock['Abx_split']: # I would rather explicitly have it search that it is not here
        return "true_positive"
    elif row['drug_class'] in ref_sus_abx:
        return "false_positive"
    else:
        return 'unknown'
    return

#print(cured_ham.info())
#print(ref_sus_abx.describe())
cured_ham['True_Positive'] = (cured_ham
                             .apply(lambda x: x['drug_class'] in ref_abx, axis = 1))


#cured_ham['False_Positive'] = (cured_ham
 #                             .apply(lambda x: x['drug_class'] in ref_sus_abx, axis=1))

#ref_abx_df['False_Negative'] = (ref_abx_df.apply(lambda x: x['abx_class'] not in cured_ham['drug_class'], axis=1))
#ref_abx_df['False_Negative'].unique()

cured_ham_dc = pd.DataFrame(cured_ham['drug_class'])

false_negatives = ref_abx_df[~(ref_abx_df['abx_class']
                             .isin(cured_ham_dc['drug_class']))]


abx_melted['abx_class'] = abx_melted['abx_class'].str.lower()
false_negatives = cured_ham_dc[~(cured_ham_dc['drug_class']
                             .isin(ref_abx_df['abx_class']))]
#false_negatives.shape ## precursor to smol_sus; using smol_sus moving forward

## sorry that the variables make less sense as I add things. this is directly related to my sleep quality 
## and how much I would like to be done with this project.


# This is where Brooke Talbot did some data cleaning in R. So I exported the above, and read in the results from her cleaning below. SHould probs rewrite what she did in python :,(
# The following code block is originally written by Brooke in R, I have rewritten it in python so that we can use one script to do everything.

# ## R to Python: Drug Class Cleaning

## based on brooke r code
#Summarizing values
## R code
#HAM$drug_class <- str_remove(HAM$drug_class, "antibiotic")
#HAM$drug_class <- str_remove(HAM$drug_class, "resistant")
#HAM$drug_class <- str_remove(HAM$drug_class, "resistance")

## python
cured_ham['drugclass_new'] = cured_ham.drug_class.str.replace('antibiotic' , '')
cured_ham['drugclass_new'] = cured_ham.drugclass_new.str.replace('resistant' , '')
cured_ham['drugclass_new'] = cured_ham.drugclass_new.str.replace('resistance' , '')

### R code
#HAM <- HAM %>% mutate(class_new = case_when(drug_class %in% c("amikacin", "kanamycin", "streptomycin","tobramycin", "kanamycin","spectinomycin", "gentamicin", "aminoglycoside") ~ "Aminoglycoside",
#                                            drug_class %in% c("phenicol", "chloramphenicol") ~ "Phenicol",
#                                            drug_class %in% c("quinolone", "fluoroquinolone", "ciprofloxacinir", "fluoroquinolones") ~ "Quinolones and Fluoroquinolones", 
#                                            drug_class %in% c("macrolide", "erythromycin", "mls", "azithromycin", "telythromycin") ~ "Macrolide", 
#                                            drug_class %in% c("tetracycline", "glycylcycline") ~ "Tetracycline", 
#                                            drug_class %in% c("ampicillin", "methicillin", "penicillin", "amoxicillinclavulanicacid") ~ "Penicillin", 
#                                            drug_class %in% c("colistin", "polymyxin", "bacitracin", "bicyclomycin") ~ "Polypeptides", 
#                                            drug_class %in% c("cephalosporin", "cefoxatin", "ceftriaxone") ~ "Cephalosporin",
#                                            drug_class %in% c("carbapenem", "penem", "meropenem") ~ "Carbapenem", 
#                                            drug_class %in% c("unclassified", "efflux", "acid", "unknown", "multidrug", "multidrugputative", "mutationsonrrnagene16s") ~ "Unclassified", 
#                                            drug_class %in% c("linezolid", "oxazolidinone") ~ "Oxazolidinone", 
#                                            drug_class %in% c("betalactam", "penam", "betalactamase") ~ "Unspecified Betalactam", 
#                                            drug_class %in% c("acridinedye") ~ "Acridine dye", 
#                                            drug_class %in% c("antibacterialfreefattyacids") ~ "Free fatty acids", 
#                                            drug_class %in% c("benzalkoniumchloride", "quaternaryammonium") ~ "Benzalkonium chlorides", 
#                                            drug_class %in% c("peptide") ~ "Unspecified peptide",
#                                            drug_class %in% c("nucleoside") ~ "Unspecified nucleoside", 
#                                            drug_class %in% c("fusidicacid") ~ "Fucidic acid", 
#                                            drug_class %in% c("sulfonamides", "sulfisoxazole", "sulfonamide") ~ "Sufonamides", 
##                                            drug_class %in% c("coppersilver") ~ "copper,silver", 
#                                            drug_class %in% c("phenicolquinolone") ~ "phenicol,quinolone", TRUE ~ drug_class))  %>% 
#               separate(class_new, into = c("d1", "d2"), sep = "([;,/])")



### python
## make new dict with drug class:drug coding that brooke implemented
cleaning_class = {"Aminoglycoside": ["amikacin", "kanamycin", "streptomycin","tobramycin", "kanamycin","spectinomycin", "gentamicin", "aminoglycoside",'aminocoumarin'],
                  "Phenicol" : ["phenicol", "chloramphenicol"],
                  "Quinolones and Fluoroquinolones" : ["quinolone", "fluoroquinolone", "ciprofloxacinir", "fluoroquinolones"],
                  "Macrolide" : ["macrolide", "erythromycin", "mls", "azithromycin", "telythromycin"],
                  "Tetracycline" : ["tetracycline", "glycylcycline"],
                  "Penicillin" : ["ampicillin", "methicillin", "penicillin", "amoxicillinclavulanicacid"],
                  "Polypeptides" : ["colistin", "polymyxin", "bacitracin", "bicyclomycin"],
                  "Cephalosporin" : ["cephalosporin", "cefoxatin", "ceftriaxone"],
                  "Carbapenem" : ["carbapenem", "penem", "meropenem"],
                  "Unclassified" : ["unclassified", "efflux", "acid", "unknown", "multidrug", "multidrugputative", 
                                    "mutationsonrrnagene16s", 'warning', 'geneismissingfromnotesfilepleaseinformcurator',  ## clean up mess from split
                                    'ant2ia', 'aph6id', 'monobactam', 'shv52a', 'rblatem1'], # again, mess from split
                  "Oxazolidinone" : ["linezolid", "oxazolidinone"],
                  "Betalactam": ["betalactam", "penam", "betalactamase"], ## no need to be "unspecificed" to removed that string
                  "Acridine dye" : ["acridinedye"],
                  "Free fatty acids" : ["antibacterialfreefattyacids"],
                  "Benzalkonium chlorides": ["benzalkoniumchloride", "quaternaryammonium"], 
                  "Unspecified peptide" : ["peptide"],
                  "Unspecified nucleoside" : ["nucleoside"],
                  "Fucidic acid" : ["fusidicacid"],
                  "Sufonamides" : ["sulfonamides", "sulfisoxazole", "sulfonamide"],
                  "copper,silver" : ["coppersilver", 'copper, silver'],
                  "phenicol,quinolone" : ["phenicolquinolone"],
                  "penicillin" : ['amoxicillin/clavulanicacid']
                }
## invert dictionary so the value is the new value, key is old value
new_d =  {vi: k  for k, v in cleaning_class.items() for vi in v}
## replace key value in column with value from dict (drug class new)
cooked_ham = cured_ham.replace({"drugclass_new": new_d})

## deep down, i am crying, because new_d worked partially but not completely
## i thought I took care of you, new_d, how could you do me like this

#### R code: this part did not need to be copied to python; the R version made some duplicate rows from the transofrmation but the python version doesn't do this
#Rearranging rows that needed to be transposed
#Dups1 <- HAM %>% filter(drug_class %in% c("coppersilver","phenicolquinolone")) %>%
#   select(-d2) %>% rename(class_new = d1)
#Dups2 <- HAM %>% filter(drug_class %in% c("coppersilver","phenicolquinolone")) %>%
#   select(-d1) %>% rename(class_new = d2)
#dupout <- HAM %>% filter(is.na(d2)) %>% select(-d2) %>% rename(class_new = d1)


# ## Back to the OG Python Script

#cooked_ham = cooked_ham.append(resfinder_results, ignore_index = True)
cooked_ham['drugclass_new'] = cooked_ham['drugclass_new'].str.lower()

### remove those with Unclassified drug class 
to_drop = ['unclassified', 'unknown', 'other', 'multidrug', '', 'target', 'efflux', # some of these are artifacts of cleaning/split
            'mutationsonproteingene', 'mfsefflux', 'genemodulating', 'mateefflux', 'rndefflux','chloramphenicolacetyltransferasecat', 'abcefflux', 'otherarg', 'genemodulatingefflux', 'rrnamethyltransferase']
cooked_ham = cooked_ham[~cooked_ham['drugclass_new'].isin(to_drop)]

## remove unspecified string bewcause it will mess up matching
cooked_ham['drugclass_new'] = cooked_ham['drugclass_new'].astype(str)
cooked_ham['drugclass_new'] = cooked_ham['drugclass_new'].map(lambda x: x.replace('unspecified ', ""))
cooked_ham['drugclass_new'] = cooked_ham['drugclass_new'].map(lambda x: x.replace('quinolones and fluoroquinolones', "quinolone"))

## some individual abx made it to drug class col, changing manually to drug class. 
cooked_ham['drugclass_new'] = cooked_ham['drugclass_new'].map(lambda x: x.replace('telithromycin', "macrolide"))
cooked_ham['drugclass_new'] = cooked_ham['drugclass_new'].map(lambda x: x.replace('daptomycin', "lipopeptide"))
cooked_ham['drugclass_new'] = cooked_ham['drugclass_new'].map(lambda x: x.replace('cefoxitin', "cephalosporin"))

cooked_ham['drugclass_new'] = cooked_ham['drugclass_new'].map(lambda x: x.replace('classcbetalactamase', 'betalactam'))
cooked_ham['drugclass_new'] = cooked_ham['drugclass_new'].map(lambda x: x.replace('classabetalactamase', 'betalactam'))
cooked_ham['drugclass_new'] = cooked_ham['drugclass_new'].map(lambda x: x.replace('classbbetalactamase', 'betalactam'))
cooked_ham['drugclass_new'] = cooked_ham['drugclass_new'].map(lambda x: x.replace('classdbetalactamase', 'betalactam'))
cooked_ham['drugclass_new'] = cooked_ham['drugclass_new'].map(lambda x: x.replace('betalactamalternatename', 'betalactam'))

#aminoglycosideaminocoumarin
cooked_ham['drugclass_new'] = cooked_ham['drugclass_new'].map(lambda x: x.replace('aminoglycosideaminocoumarin', 'aminoglycoside'))
cooked_ham['drugclass_new'] = cooked_ham['drugclass_new'].map(lambda x: x.replace('aminoglycosidealternatename', 'aminoglycoside'))
cooked_ham['drugclass_new'] = cooked_ham['drugclass_new'].map(lambda x: x.replace('aminoglycosidephosphotransferase', 'aminoglycoside')) ## phosphotransferase would be filtered out as other drug class, so ignore here
cooked_ham['drugclass_new'] = cooked_ham['drugclass_new'].map(lambda x: x.replace('aminoglycosidenucleotidyltransferase', 'aminoglycoside')) ## same w nucleo...
cooked_ham['drugclass_new'] = cooked_ham['drugclass_new'].map(lambda x: x.replace('aminoglycosideacetyltransferase', 'aminoglycoside')) ## same w acetyl..
#cooked_ham['drugclass_new'] = cooked_ham['drugclass_new'].map(lambda x: x.replace('aminoglycosideaminocoumarin', 'aminoglycoside')) ## same w acetyl..


cooked_ham['drugclass_new'] = cooked_ham['drugclass_new'].map(lambda x: x.replace('tetracyclineefflux', 'tetracycline')) ##

## those that fall into "other" drug class are left as the abx
# we can keep triclosan bc some abx map to triclosan 

## inspect that it worked in interactive
#cooked_ham['drugclass_new'].unique()
#cooked_ham.shape ## shorter than above. bc drops those with unclassified / unknown

def assign_true_pos(x):

    if x in(ref_abx.unique()):
        return "true_positive"
    elif x in(smol_sus['abx_class'].unique()):
        return "false_positive"
    else:
        return "unknown"

cooked_ham['true_positive'] = cooked_ham['drugclass_new'].apply(lambda x: assign_true_pos(x)) # true is true pos, false is false neg
combo_counts = cooked_ham.true_positive.value_counts()
combo_name = outdir + "combo_counts_" + res_name + ".txt"
combo_counts.to_csv(combo_name)

# first need to do some grouping by tool in cooked_ham
grouped_ham = cooked_ham.groupby(['analysis_software_name'])
ham_name = outdir + "cooked_ham_w_true_pos_" + res_name + ".csv"
cooked_ham.to_csv(ham_name)


# Analysis below
grp_abx_results = grouped_ham['drugclass_new'].value_counts().to_frame()
name_grp_results = outdir + "grouped_by_tool_drug_class" + res_name + ".csv"
grp_abx_results.to_csv(name_grp_results)
#grp_abx_results


pos_count = grouped_ham['true_positive'].value_counts().to_frame().unstack(1, fill_value = 0)
#pos_count.columns = ['analysis_software_name', 'positive_classification', 'count']

### get false neg dataset
abx_melted['abx_class'] = abx_melted['abx_class'].str.lower() # copied above but def need here
## drop other from abx_meltered because we excluded unknowns
abx_melted = abx_melted[abx_melted.abx_class != 'other']

## get true abx not in our sample
not_in_mock = abx_melted[~abx_melted['abx_class'].isin(ref_abx)]
not_in_mock['abx_class'].unique()
mock_negatives = not_in_mock['abx_class'].unique() # list of what would be true negative values
## use smol_sus for only what is KNOWN as negative

def fetch_negatives(df, tool):
    df = df[df.analysis_software_name == tool]
    
    ## filter for the tool
    not_in_ham = abx_melted[~abx_melted['abx_class'].isin(df['drugclass_new'])]
    
    return not_in_ham['abx_class'].unique()

tool_list = list(cooked_ham['analysis_software_name'].unique())
negs = {}
total_negatives = []
for i in tool_list:
    intermediate = fetch_negatives(cooked_ham, i)
   # print(i, "\n",len(intermediate))
  #  print(intermediate)
    ## these appear to be real true negatives - these Abx classes exist, and they are not in any of the hams
    name = str(i )
    # join whats not in ham and not in mock for true neg
    negs[name] = intermediate
    for n in intermediate:
        if n not in total_negatives and n not in cooked_ham['drugclass_new']:
            total_negatives.append(n)

all_pos_abx = resistant_mock['abx_class'].unique()
neg_abx = smol_sus.abx_class.unique()
neg_count = pd.DataFrame(columns=['tool', "false-neg", "true-neg"])
for tool in negs:
    tool_falseneg_count = 0
    tool_trueneg_count = 0
    negatives = negs[tool]
    for n in negatives:
        #print(tool, n, "\n")
        #print([n])
        if n in neg_abx: #neg_abx for known negative, mock_negatives for negative results including unknown susceptibility
            #print("true_negative: ", tool, n)
            tool_trueneg_count += 1
    
        elif n in all_pos_abx:
            #print("false negative: ", tool, n)
            tool_falseneg_count += 1
    
    df2 = {'tool': tool, 'false-neg': tool_falseneg_count, 'true-neg': tool_trueneg_count}
    neg_count = neg_count.append(df2, ignore_index = True)
    
    print("False negatives from ", tool, ": ", tool_falseneg_count)
    print("True negatives from ", tool, ": ", tool_trueneg_count)


counts = pd.merge(pos_count, neg_count, right_on = "tool", how = "outer",left_index=True, right_index=False)  
#counts ## this spits out an error, but we can ignore it bc it's due to the double labels from pos counts

## what re counts if we merge all results
pos_count_total = cooked_ham['true_positive'].value_counts().to_frame().unstack(1, fill_value = 0)
#pos_count.columns = ['analysis_software_name', 'positive_classification', 'count']\

## negs 
## drugs not detected but that exist in the world
not_in_ham = ref_abx[~ref_abx.isin(cooked_ham['drugclass_new'])]
    
#not_in_ham
negs_in_ham = cooked_ham['drugclass_new'][~cooked_ham['drugclass_new'].isin(ref_abx)]
#negs_in_ham.unique()

cooked_ham[cooked_ham['drugclass_new'].isin(neg_abx)] ## all false positives are nitro for oqxB/A gene

## get false/true negs
tot_trueneg_count = 0
tot_falseneg_count = 0
for n in total_negatives:
        #print(tool, n, "\n")
      #  print([n])
        if n in neg_abx: #neg_abx for known negative, mock_negatives for negative results including unknown susceptibility
            #print("true_negative: ", tool, n)
            if n not in cooked_ham['drugclass_new']:
                tot_trueneg_count += 1
                #print("true neg: ", n)
        elif n in all_pos_abx:
            #print("false negative: ", tool, n)
            if n not in cooked_ham['drugclass_new']:
                tot_falseneg_count += 1
                #print('false_neg:', n)
    
#print("False negatives: ", tot_falseneg_count)
#print("True negatives: ", tot_trueneg_count)


# # Thanksgiving Ham
# 
# The following table is what all this code is for. 
## sensitivity / specificity analysis
## sensitivity = true_positives / (true_positives + false_negatives)
counts['sensitivity'] = counts[('true_positive', 'true_positive')] / (counts[('true_positive','true_positive')] + counts['false-neg'])
## precision = true positives / false_positives + true_positives
counts['precision'] = counts[('true_positive', 'true_positive')] / ( counts['true_positive', 'false_positive'] + counts[('true_positive', 'true_positive')] )
## specificity = true_negative / (true_negative + false_positi
counts['specificity'] = counts['true-neg'] / (counts['true-neg'] + counts[('true_positive', 'false_positive')])
## accuracy = (true_positive + true_negative) / (true_positive + false_positive + true_negative)
counts['accuracy'] = (counts[('true_positive', 'true_positive')] + counts['true-neg']) / (counts[('true_positive', 'true_positive')] + counts['true_positive','false_positive'] + counts['true-neg'] )
## recall = true pos / (true pos  + false neg)
counts['recall'] = counts[('true_positive', 'true_positive')] / (counts[('true_positive', 'false_positive')] + counts['false-neg'])
counts['recall'] = pd.to_numeric(counts['recall'])
# F1 currently faulty (returning values outside expected range) so removing from the pipeline
## 2 * (precision * recall) / (precision + recall)
#counts['F1'] = 2 * ( (counts['precision'] * counts['recall']) / (counts['precision'] + counts['recall']) )
#except ZeroDivisionError:
#    counts['F1'] = 0
counts['percent_unclassified'] = counts[('true_positive', 'unknown')] / (counts[('true_positive', 'true_positive')] + counts[('true_positive', 'false_positive')] + counts[('true_positive', 'unknown')])


print("Thanksgiving Ham, ", this_run_res, ": ")
name = outdir + "thanksgiving_ham_" + res_name + ".csv"
counts.to_csv(name)
print(counts) ## print out if interactive; does nothing if command line


# # Canned Ham
# condensing the results
# 

# In[1424]:
cooked_ham = cooked_ham.assign(condensed_gene = cooked_ham.groupby('analysis_software_name')['input_gene_start'].shift(-1))

def condense_results(df):
    start_col = df['input_gene_start']
    stop_col = df['input_gene_stop']
    next_row = df['condensed_gene']
    keep_val = ""
    condense_val = ""
    unconclusive_val = ""
    
    if next_row < stop_col: # if the start of the next gene overlaps with the end of THIS gene
        condense_val = "condense"
    elif stop_col < next_row: 
        keep_val = "keep"
    else:
        unconclusive_val = "unconclusive"
    
    message = str( condense_val + keep_val + unconclusive_val)
    return(message)


cooked_ham['condense_action'] = cooked_ham.apply(lambda x: condense_results(x), axis=1) ## does this need to be grouped by analysis software name ?
#cooked_ham['condense_action'].describe()
## looks like there are 1811 instances where AMR genes overlap. Lets remove these and see what happens. 

canned_ham = cooked_ham[cooked_ham['condense_action'] != "condense"]
## i am very proud of myself for this name
## its the little things in life that bring me smiles

## positives
grouped_can = canned_ham.groupby(['analysis_software_name'])
pos_count2 = grouped_can['true_positive'].value_counts().to_frame().unstack(1, fill_value = 0)

## add negatives
negs2={}
for i in tool_list:
    intermediate = fetch_negatives(canned_ham, i)
    #print(i, "\n",len(intermediate))
    ## these appear to be real true negatives - these Abx classes exist, and they are not in any of the hams
    name = str(i )
    # join whats not in ham and not in mock for true neg
    negs2[name] = intermediate


## negative counts
neg_count2 = pd.DataFrame(columns=['tool', "false-neg", "true-neg"])
for tool in negs2:
    tool_falseneg_count = 0
    tool_trueneg_count = 0
    negatives = negs2[tool]
    for n in negatives:
       # print(tool, n, "\n")
        #print([n])
        if n in neg_abx: 
            #print("true_negative: ", tool, n)
            tool_trueneg_count += 1
    
        elif n in neg_abx: ## only things that are known to be negative
            #print("false negative: ", tool, n)
            tool_falseneg_count += 1
    
    df3 = {'tool': tool, 'false-neg': tool_falseneg_count, 'true-neg': tool_trueneg_count}
    neg_count2 = neg_count2.append(df3, ignore_index = True)
    
    #print("False negatives from ", tool, ": ", tool_falseneg_count)
    #print("Truenegatives from ", tool, ": ", tool_trueneg_count)

## merge this all together
counts2 = pd.merge(pos_count2, neg_count2, right_on = "tool", how = "outer",left_index=True, right_index=False)  
#counts2 ## this spits out an error, but we can ignore it 

## sensitivity / specificity analysis
## sensitivity = true_positives / (true_positives + false_negatives)
counts2['sensitivity'] = counts2[('true_positive','true_positive')] / (counts2[('true_positive','true_positive')] + counts2['false-neg'])
## precision
counts2['precision'] = counts2[('true_positive','true_positive')] / ( counts2['true_positive','false_positive'] + counts2[('true_positive','true_positive')] )
## specificity = true_negative / (true_negative + false_positive)
counts2['specificity'] = counts2['true-neg'] / (counts2['true-neg'] + counts2[('true_positive', 'false_positive')])
## if we do true neg (aka if it is not zero:)
## accuracy = (true_positive + true_negative) / (true_positive + false_positive + true_negative)
counts2['accuracy'] = (counts2[('true_positive', 'true_positive')] + counts2['true-neg']) / (counts2[('true_positive','true_positive')] + counts['true_positive','false_positive'] + counts['true-neg'] )
## recall
## true pos / (true pos  + false neg)
counts2['recall'] = counts2[('true_positive','true_positive')] / (counts2[('true_positive', 'true_positive')] + counts2['false-neg'])
counts2['recall'] = pd.to_numeric(counts2['recall'])
# F1 
## 2 * (precision * recall) / (precision + recall)
#counts2['F1'] = 2 * ( (counts2['precision'] * counts2['recall']) / (counts2['precision'] + counts2['recall']) )
#except ZeroDivisionError:
#    counts['F1'] = 0
counts2['percent_unclassified'] = counts2[('true_positive', 'unknown')] / (counts2[('true_positive', 'true_positive')] + counts2[('true_positive', 'false_positive')] + counts2[('true_positive', 'unknown')])

#print("Canned Ham Thanksgiving Table, ", this_run_res, " :")
# no need to print this
name2 = outdir + "canned_ham_" + res_name + ".csv"
counts2.to_csv(name2)
counts2 ## prints if interactive, ignored if not

## combine results of all tools
#count specificity 
tot_false_pos =  sum(counts[('true_positive','false_positive')])
tot_true_pos =  sum(counts[('true_positive', 'true_positive')])
tot_false_neg =  min(counts['false-neg'])
tot_true_neg = min(counts['true-neg']) 
tot_unknown = sum(counts['true_positive', 'unknown'])

#######
## combo stats
## sensitivity = true_positives / (true_positives + false_negatives)
sensitivity = tot_true_pos / (tot_true_pos + tot_false_neg)

## precision
precision = tot_true_pos / ( tot_false_pos + tot_true_pos )

## specificity = true_negative / (true_negative + false_positive)
specificity = tot_true_neg / (tot_true_neg + tot_false_pos)

## accuracy = (true_positive + true_negative) / (true_positive + false_positive + true_negative)
accuracy = (tot_true_pos + tot_true_neg) / (tot_true_pos + tot_false_pos + tot_true_neg )

## recall
## true pos / (true pos  + false neg)
recall = tot_true_pos / (tot_true_pos + tot_false_neg)

# F1 
## 2 * (precision * recall) / (precision + recall)
#
#F1 = 2 * ( precision * recall / (precision + recall) )
#except ZeroDivisionError:
#    counts['F1'] = 0
percent_unclassified = tot_unknown / (tot_true_pos + tot_false_pos + tot_unknown)

print("combo stats (compiled outputs of all tools): ", "\n", "sensitivity: ", sensitivity, "\n specificity",specificity, "\n precision", precision, "\n accuracy", accuracy, "\n recall", recall) 
print(" percent unknown: ", percent_unclassified)

