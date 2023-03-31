#! /usr/bin/env python3
"""Calculates the length wise error comparison for two models with/without overlapping.
Also generates an aggregate plot.
Requires folders filled with {species}/length_wise_eval.log files from
helixer_scratch/cluster_eval_predictions/evaluations/length_wise/length-wise-eval-from-cluster-jobs.sh"""

import os
import numpy as np
import argparse
import matplotlib.pyplot as plt

# just hardcoded names in here for ease of execution
# names are also found in the final eval google docs spreadsheets
names = {
    'plants': {
        'Acomosus': 'Ananas_comosus',
        'Ahypochondriacus': 'Amaranthus_hypochondriacus',
        'Alyrata': 'Arabidopsis_lyrata',
        'Aofficinalis': 'Asparagus_officinalis',
        'Athaliana': 'Arabidopsis_thaliana',
        'Atrichopoda': 'Amborella_trichopoda',
        'Bdistachyon': 'Brachypodium_distachyon',
        'Boleraceacapitata': 'Brassica_oleracea',
        'Carietinum': 'Cicer_arietinum',
        'Cclementina': 'Citrus_clementina',
        'Cgrandiflora': 'Capsella_grandiflora',
        'Cpapaya': 'Carica_papaya',
        'Cquinoa': 'Chenopodium_quinoa',
        'Creinhardtii': 'Chlamydomonas_reinhardtii',
        'Crubella': 'Capsella_rubella',
        'Csativus': 'Cucumis_sativus',
        'Csinensis': 'Citrus_sinensis',
        'CsubellipsoideaC169': 'Coccomyxa_subellipsoidea_C-169',
        'Czofingiensis': 'Chromochloris_zofingiensis',
        'Dcarota': 'Daucus_carota',
        'Dsalina': 'Dunaliella_salina',
        'Egrandis': 'Eucalyptus_grandis',
        'Esalsugineum': 'Eutrema_salsugineum',
        'Fvesca': 'Fragaria_vesca',
        'Gmax': 'Glycine_max',
        'Graimondii': 'Gossypium_raimondii',
        'Hannuus': 'Helianthus_annuus',
        'Hvulgare': 'Hordeum_vulgare',
        'Kfedtschenkoi': 'Kalanchoe_fedtschenkoi',
        'Lsativa': 'Lactuca_sativa',
        'Lusitatissimum': 'Linum_usitatissimum',
        'Macuminata': 'Musa_acuminata',
        'Mdomestica': 'Malus_domestica',
        'Mesculenta': 'Manihot_esculenta',
        'Mguttatus': 'Mimulus_guttatus',
        'Mpolymorpha': 'Marchantia_polymorpha',
        'MpusillaCCMP1545': 'Micromonas_pusilla',
        'MspRCC299': 'Micromonas_sp._RCC299',
        'Mtruncatula': 'Medicago_truncatula',
        'Oeuropaea': 'Olea_europaea',
        'Olucimarinus': 'Ostreococcus_sp._lucimarinus',
        'Osativa': 'Oryza_sativa',
        'Othomaeum': 'Oropetium_thomaeum',
        'Ppatens': 'Physcomitrella_patens',
        'Ppersica': 'Prunus_persica',
        'Ptrichocarpa': 'Populus_trichocarpa',
        'Pumbilicalis': 'Porphyra_umbilicalis',
        'Rcommunis': 'Ricinus_communis',
        'Sbicolor': 'Sorghum_bicolor',
        'Sitalica': 'Setaria_italica',
        'Slycopersicum': 'Solanum_lycopersicum',
        'Smoellendorffii': 'Selaginella_moellendorffii',
        'Spolyrhiza': 'Spirodela_polyrhiza',
        'Stuberosum': 'Solanum_tuberosum',
        'Taestivum': 'Triticum_aestivum',
        'Tcacao': 'Theobroma_cacao',
        'Vcarteri': 'Volvox_carteri',
        'Vvinifera': 'Vitis_vinifera',
        'Zmarina': 'Zostera_marina',
        'Zmays': 'Zea_mays'
    },
    'animals': {
        'acanthochromis_polyacanthus': 'acanthochromis_polyacanthus',
        'ailuropoda_melanoleuca': 'ailuropoda_melanoleuca',
        'amphilophus_citrinellus': 'amphilophus_citrinellus',
        'amphiprion_ocellaris': 'amphiprion_ocellaris',
        'amphiprion_percula': 'amphiprion_percula',
        'anabas_testudineus': 'anabas_testudineus',
        'anas_platyrhynchos_platyrhynchos': 'anas_platyrhynchos_platyrhynchos',
        'anolis_carolinensis': 'anolis_carolinensis',
        'anser_brachyrhynchus': 'anser_brachyrhynchus',
        'aotus_nancymaae': 'aotus_nancymaae',
        'apteryx_haastii': 'apteryx_haastii',
        'apteryx_owenii': 'apteryx_owenii',
        'apteryx_rowi': 'apteryx_rowi',
        'astatotilapia_calliptera': 'astatotilapia_calliptera',
        'astyanax_mexicanus': 'astyanax_mexicanus',
        'betta_splendens': 'betta_splendens',
        'bison_bison_bison': 'bison_bison_bison',
        'bos_indicus_hybrid': 'bos_indicus',
        'bos_mutus': 'bos_mutus',
        'bos_taurus': 'bos_taurus',
        'caenorhabditis_elegans': 'caenorhabditis_elegans',
        'calidris_pugnax': 'calidris_pugnax',
        'calidris_pygmaea': 'calidris_pygmaea',
        'callithrix_jacchus': 'callithrix_jacchus',
        'callorhinchus_milii': 'callorhinchus_milii',
        'canis_familiaris': 'canis_lupus_familiaris',
        'canis_lupus_dingo': 'canis_lupus_dingo',
        'capra_hircus': 'capra_hircus',
        'carlito_syrichta': 'carlito_syrichta',
        'castor_canadensis': 'castor_canadensis',
        'cavia_aperea': 'cavia_aperea',
        'cavia_porcellus': 'cavia_porcellus',
        'cebus_capucinus': 'cebus_capucinus',
        'cercocebus_atys': 'cercocebus_atys',
        'chelonoidis_abingdonii': 'chelonoidis_abingdonii',
        'chinchilla_lanigera': 'chinchilla_lanigera',
        'chlorocebus_sabaeus': 'chlorocebus_sabaeus',
        'choloepus_hoffmanni': 'choloepus_hoffmanni',
        'chrysemys_picta_bellii': 'chrysemys_picta_bellii',
        'ciona_intestinalis': 'ciona_intestinalis',
        'ciona_savignyi': 'ciona_savignyi',
        'clupea_harengus': 'clupea_harengus',
        'colobus_angolensis_palliatus': 'colobus_angolensis_palliatus',
        'cottoperca_gobio': 'cottoperca_gobio',
        'coturnix_japonica': 'coturnix_japonica',
        'cricetulus_griseus_picr': 'cricetulus_griseus',
        'crocodylus_porosus': 'crocodylus_porosus',
        'cyanistes_caeruleus': 'cyanistes_caeruleus',
        'cynoglossus_semilaevis': 'cynoglossus_semilaevis',
        'cyprinodon_variegatus': 'cyprinodon_variegatus',
        'danio_rerio': 'danio_rerio',
        'dasypus_novemcinctus': 'dasypus_novemcinctus',
        'denticeps_clupeoides': 'denticeps_clupeoides',
        'dipodomys_ordii': 'dipodomys_ordii',
        'dromaius_novaehollandiae': 'dromaius_novaehollandiae',
        'drosophila_melanogaster': 'drosophila_melanogaster',
        'echinops_telfairi': 'echinops_telfairi',
        'electrophorus_electricus': 'electrophorus_electricus',
        'eptatretus_burgeri': 'eptatretus_burgeri',
        'equus_asinus_asinus': 'equus_asinus_asinus',
        'equus_caballus': 'equus_caballus',
        'erinaceus_europaeus': 'erinaceus_europaeus',
        'erpetoichthys_calabaricus': 'erpetoichthys_calabaricus',
        'esox_lucius': 'esox_lucius',
        'felis_catus': 'felis_catus',
        'ficedula_albicollis': 'ficedula_albicollis',
        'fukomys_damarensis': 'fukomys_damarensis',
        'fundulus_heteroclitus': 'fundulus_heteroclitus',
        'gadus_morhua': 'gadus_morhua',
        'gallus_gallus': 'gallus_gallus',
        'gambusia_affinis': 'gambusia_affinis',
        'gasterosteus_aculeatus': 'gasterosteus_aculeatus',
        'gopherus_agassizii': 'gopherus_agassizii',
        'gorilla_gorilla': 'gorilla_gorilla',
        'gouania_willdenowi': 'gouania_willdenowi',
        'haplochromis_burtoni': 'haplochromis_burtoni',
        'heterocephalus_glaber_female': 'heterocephalus_glaber',
        'hippocampus_comes': 'hippocampus_comes',
        'homo_sapiens': 'homo_sapiens',
        'hucho_hucho': 'hucho_hucho',
        'ictalurus_punctatus': 'ictalurus_punctatus',
        'ictidomys_tridecemlineatus': 'ictidomys_tridecemlineatus',
        'jaculus_jaculus': 'jaculus_jaculus',
        'junco_hyemalis': 'junco_hyemalis',
        'kryptolebias_marmoratus': 'kryptolebias_marmoratus',
        'labrus_bergylta': 'labrus_bergylta',
        'larimichthys_crocea': 'larimichthys_crocea',
        'lates_calcarifer': 'lates_calcarifer',
        'latimeria_chalumnae': 'latimeria_chalumnae',
        'lepidothrix_coronata': 'lepidothrix_coronata',
        'lepisosteus_oculatus': 'lepisosteus_oculatus',
        'lonchura_striata_domestica': 'lonchura_striata_domestica',
        'loxodonta_africana': 'loxodonta_africana',
        'macaca_fascicularis': 'macaca_fascicularis',
        'macaca_mulatta': 'macaca_mulatta',
        'macaca_nemestrina': 'macaca_nemestrina',
        'manacus_vitellinus': 'manacus_vitellinus',
        'mandrillus_leucophaeus': 'mandrillus_leucophaeus',
        'marmota_marmota_marmota': 'marmota_marmota_marmota',
        'mastacembelus_armatus': 'mastacembelus_armatus',
        'maylandia_zebra': 'maylandia_zebra',
        'meleagris_gallopavo': 'meleagris_gallopavo',
        'melopsittacus_undulatus': 'melopsittacus_undulatus',
        'meriones_unguiculatus': 'meriones_unguiculatus',
        'mesocricetus_auratus': 'mesocricetus_auratus',
        'microcebus_murinus': 'microcebus_murinus',
        'microtus_ochrogaster': 'microtus_ochrogaster',
        'mola_mola': 'mola_mola',
        'monodelphis_domestica': 'monodelphis_domestica',
        'monopterus_albus': 'monopterus_albus',
        'mus_caroli': 'mus_caroli',
        'mus_musculus': 'mus_musculus',
        'mus_pahari': 'mus_pahari',
        'mus_spicilegus': 'mus_spicilegus',
        'mus_spretus': 'mus_spretus',
        'mustela_putorius_furo': 'mustela_putorius_furo',
        'myotis_lucifugus': 'myotis_lucifugus',
        'nannospalax_galili': 'nannospalax_galili',
        'neolamprologus_brichardi': 'neolamprologus_brichardi',
        'neovison_vison': 'neovison_vison',
        'nomascus_leucogenys': 'nomascus_leucogenys',
        'notamacropus_eugenii': 'notamacropus_eugenii',
        'notechis_scutatus': 'notechis_scutatus',
        'nothoprocta_perdicaria': 'nothoprocta_perdicaria',
        'numida_meleagris': 'numida_meleagris',
        'ochotona_princeps': 'ochotona_princeps',
        'octodon_degus': 'octodon_degus',
        'oreochromis_niloticus': 'oreochromis_niloticus',
        'ornithorhynchus_anatinus': 'ornithorhynchus_anatinus',
        'oryctolagus_cuniculus': 'oryctolagus_cuniculus',
        'oryzias_latipes': 'oryzias_latipes',
        'oryzias_melastigma': 'oryzias_melastigma',
        'otolemur_garnettii': 'otolemur_garnettii',
        'ovis_aries': 'ovis_aries',
        'pan_paniscus': 'pan_paniscus',
        'pan_troglodytes': 'pan_troglodytes',
        'panthera_pardus': 'panthera_pardus',
        'panthera_tigris_altaica': 'panthera_tigris_altaica',
        'papio_anubis': 'papio_anubis',
        'parambassis_ranga': 'parambassis_ranga',
        'paramormyrops_kingsleyae': 'paramormyrops_kingsleyae',
        'parus_major': 'parus_major',
        'pelodiscus_sinensis': 'pelodiscus_sinensis',
        'periophthalmus_magnuspinnatus': 'periophthalmus_magnuspinnatus',
        'peromyscus_maniculatus_bairdii': 'peromyscus_maniculatus_bairdii',
        'petromyzon_marinus': 'petromyzon_marinus',
        'phascolarctos_cinereus': 'phascolarctos_cinereus',
        'piliocolobus_tephrosceles': 'piliocolobus_tephrosceles',
        'poecilia_formosa': 'poecilia_formosa',
        'poecilia_latipinna': 'poecilia_latipinna',
        'poecilia_mexicana': 'poecilia_mexicana',
        'poecilia_reticulata': 'poecilia_reticulata',
        'pogona_vitticeps': 'pogona_vitticeps',
        'pongo_abelii': 'pongo_abelii',
        'procavia_capensis': 'procavia_capensis',
        'prolemur_simus': 'prolemur_simus',
        'propithecus_coquereli': 'propithecus_coquereli',
        'pteropus_vampyrus': 'pteropus_vampyrus',
        'pundamilia_nyererei': 'pundamilia_nyererei',
        'pygocentrus_nattereri': 'pygocentrus_nattereri',
        'rattus_norvegicus': 'rattus_norvegicus',
        'rhinopithecus_bieti': 'rhinopithecus_bieti',
        'rhinopithecus_roxellana': 'rhinopithecus_roxellana',
        'saimiri_boliviensis_boliviensis': 'saimiri_boliviensis_boliviensis',
        'salvator_merianae': 'salvator_merianae',
        'sarcophilus_harrisii': 'sarcophilus_harrisii',
        'scleropages_formosus': 'scleropages_formosus',
        'scophthalmus_maximus': 'scophthalmus_maximus',
        'serinus_canaria': 'serinus_canaria',
        'seriola_dumerili': 'seriola_dumerili',
        'seriola_lalandi_dorsalis': 'seriola_lalandi_dorsalis',
        'sorex_araneus': 'sorex_araneus',
        'spermophilus_dauricus': 'spermophilus_dauricus',
        'sphenodon_punctatus': 'sphenodon_punctatus',
        'stegastes_partitus': 'stegastes_partitus',
        'sus_scrofa': 'sus_scrofa',
        'taeniopygia_guttata': 'taeniopygia_guttata',
        'takifugu_rubripes': 'takifugu_rubripes',
        'tetraodon_nigroviridis': 'tetraodon_nigroviridis',
        'theropithecus_gelada': 'theropithecus_gelada',
        'tupaia_belangeri': 'tupaia_belangeri',
        'tursiops_truncatus': 'tursiops_truncatus',
        'urocitellus_parryii': 'urocitellus_parryii',
        'ursus_americanus': 'ursus_americanus',
        'ursus_maritimus': 'ursus_maritimus',
        'vicugna_pacos': 'vicugna_pacos',
        'vombatus_ursinus': 'vombatus_ursinus',
        'vulpes_vulpes': 'vulpes_vulpes',
        'xenopus_tropicalis': 'xenopus_tropicalis',
        'xiphophorus_couchianus': 'xiphophorus_couchianus',
        'xiphophorus_maculatus': 'xiphophorus_maculatus',
        'zonotrichia_albicollis': 'zonotrichia_albicollis'
    }
}

def plot_comparison(f1_before, f1_after, acc_before, acc_after, title, picture_name, folder,
                    tight=False):
    plt.cla()
    plt.title(title)
    # old colors were 'chocolate' and 'royalblue'
    plt.plot(range(100), f1_before, color='tab:red', linestyle='dashed',
             label='Regular Genic F1')
    plt.plot(range(100), f1_after, color='tab:red', label='Genic F1 with Overlapping')
    plt.plot(range(100), acc_before, color='tab:purple', linestyle='dashed',
             label='Regular Accuracy')
    plt.plot(range(100), acc_after, color='tab:purple', label='Accuracy with Overlapping')
    plt.ylim((0.0, 1.0))

    ticks = [0, 25, 50, 75, 100]
    plt.xticks(ticks, [str(t * 200) for t in ticks])
    plt.xlabel('Basepair Offset in Sequence')

    if 'Olucimarinus' in picture_name:
        plt.legend(loc='upper right')
    else:
        plt.legend(loc='lower left')
    file_path = os.path.join(folder, picture_name)
    if tight:
        plt.savefig(file_path, bbox_inches='tight' )
    else:
        plt.savefig(file_path)
    print(file_path, 'saved')


parser = argparse.ArgumentParser()
parser.add_argument('-before', '--before_main_folder', type=str, required=True)
parser.add_argument('-after', '--after_main_folder', type=str, required=True)
parser.add_argument('-o', '--output_folder', type=str, required=True)
parser.add_argument('-d', '--dataset', type=str, default='plants')
parser.add_argument('-oa', '--output-aggregate', action='store_true')
args = parser.parse_args()

assert args.dataset in ['plants', 'animals']

genic_f1s = {'before': [], 'after': []}
accuracies = {'before': [], 'after': []}

for species in os.listdir(args.before_main_folder):
    if not os.path.isdir(os.path.join(args.before_main_folder, species)):
        continue
    log_files = {
        'before': os.path.join(args.before_main_folder, species, 'length_wise_eval.log'),
        'after': os.path.join(args.after_main_folder, species, 'length_wise_eval.log'),
    }

    not_good = False
    for log_file_path in log_files.values():
        if not os.path.exists(log_file_path) or not os.path.getsize(log_file_path) > 0:
            print(f'Log file {log_file_path} is empty or not existing.')
            not_good = True
    if not_good:
        continue

    for type_, log_file_path in log_files.items():
        # parse metric table
        species_genic_f1s, species_accuracies = [], []
        f = open(log_file_path)
        while True:
            line = next(f)
            if line.startswith('| genic'):
                species_genic_f1s.append(float(line.strip().split('|')[4].strip()))
                # parse total accuracy
                next(f)
                species_accuracies.append(float(next(f).strip().split(' ')[-1]))
                if len(species_genic_f1s) == 100:
                    genic_f1s[type_].append(species_genic_f1s)
                    accuracies[type_].append(species_accuracies)
                    break
    renamed_species = names[args.dataset][species]
    plot_comparison(genic_f1s['before'][-1],
                    genic_f1s['after'][-1],
                    accuracies['before'][-1],
                    accuracies['after'][-1],
                    # f'Performance by Sequence Position of {species}',
                    f'{renamed_species.capitalize()}',
                    f'{species}_comparison',
                    args.output_folder)

# make aggregate plot
f1s_avg, accs_avg = {}, {}
for type_, values in genic_f1s.items():
    f1s_avg[type_] = np.mean(np.array(genic_f1s[type_]), axis=0)
    accs_avg[type_] = np.mean(np.array(accuracies[type_]), axis=0)

plot_comparison(f1s_avg['before'],
                f1s_avg['after'],
                accs_avg['before'],
                accs_avg['after'],
                f'Average {args.dataset.capitalize()} Performance by Input Sequence Position',
                f'aggregate_comparison',
                args.output_folder,
                tight=True)

if args.output_aggregate:
    # write aggregate info to disk as csv
    f = open(f'{args.output_folder}/{args.dataset.capitalize()}_aggregate.csv', 'w')
    print('position,f1,f1_with_overlapping,acc,acc_with_overlapping', file=f)
    for i in range(100):
        print(','.join([str(e) for e in [i * 200, f1s_avg['before'][i], f1s_avg['after'][i],
                          accs_avg['before'][i], accs_avg['after'][i]]]), file=f)

