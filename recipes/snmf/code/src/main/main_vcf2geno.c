/*
 *     vcf2geno, file: main_vcf2geno.c
 *     Copyright (C) 2013 Eric Frichot
 *
 *     This program is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     This program is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <math.h>

#include "../convert/vcf2geno.h"
#include "../convert/register_convert.h"
#include "../io/read.h"
#include "../io/io_tools.h"

int main (int argc, char *argv[]) {

	int M;	 			// number of SNPs
	int N;				// number of individuals
	int removed;			// number of removed CNVs
	char input_file[512];		// input file
	char output_file[512];		// output genotype file
	char snp_bp_file[512];		// snp file
	char removed_bp_file[512];	// removed snp file
        char *tmp;

	analyse_param_convert(argc, argv, input_file, output_file, "geno");

        tmp = remove_ext(output_file,'.','/');
        strcpy(snp_bp_file, tmp);
        strcat(snp_bp_file, ".vcfsnp");

        strcpy(removed_bp_file, tmp);
        strcat(removed_bp_file, ".removed");

	vcf2geno(input_file, output_file, &N, &M, snp_bp_file, removed_bp_file, &removed);

	print_convert(N, M);

        printf("For SNP info, please check %s.\n\n",snp_bp_file);

        printf("%d line(s) were removed because these are not SNPs.\n", removed);
        printf("Please, check %s file, for more informations.\n\n",removed_bp_file);

	free(tmp);

	return 0;

}

