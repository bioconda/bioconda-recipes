/*
    sNMF, file: print_ce.c
    Copyright (C) 2013 Eric Frichot

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


#include "print_ce.h"
#include <stdio.h>
#include <stdlib.h>

// print_help

void print_help_ce() 
{
   printf("\nHELP: ./crossEntropy options \n\n"
         "mandatory:\n"
         "        -x genotype_file      -- genotype file (in .geno format)\n"
         "        -K K                  -- the number of ancestral populations\n\n"

         "optional:\n"
         "        -h                    -- help\n"
         "        -m ploidy             -- 1 if haploid, 2 if diploid     	 (default: 2)\n"
         "        -q input_file_I.Q     -- individual admixture coefficient file (default: genotype_file_I.K.Q)\n"
         "        -g input_file_I.F     -- ancestral genotype frequency file 	 (default: genotype_file_I.K.G)\n"
         "        -i input_file_I.geno  -- genotype file with masked genotypes 	 (default: genotype_file_I.geno)\n\n"
        );
}

// print_summary

void print_summary_ce ( int N, int M, int K, 
                        int m, char *input, char *input_Q, 
                        char *input_F, char *input_I) 
{

           printf("summary of the options:\n\n"
                "        -n (number of individuals)         %d\n"  
                "        -L (number of loci)                %d\n"
                "        -K (number of ancestral pops)      %d\n"
                "        -x (genotype file)                 %s\n"
                "        -q (individual admixture)          %s\n"
                "        -g (ancestral frequencies)         %s\n"
                "        -i (with masked genotypes)         %s\n"
                , N, M, K, input, input_Q, input_F, input_I);

        if (m == 1)
                printf("        - haploid\n\n");
        else if (m == 2)
                printf("        - diploid\n\n");
        else 
                printf("        - %d-ploid\n\n",m);
}

