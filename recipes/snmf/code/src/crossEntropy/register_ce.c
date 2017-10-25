/*
    sNMF, file: register_ce.c
    Copyright (C) 2013 François Mathieu, Eric Frichot

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


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "register_ce.h"
#include "../sNMF/print_snmf.h"
#include "print_ce.h"
#include "error_ce.h"
#include "../io/io_tools.h"

// analyse_param

void analyse_param_ce(	int argc, char *argv[], int* m,
			int* K, char *input, char* input_file_Q, 
			char* input_file_F, char *input_file_I) 
{
        int i;
	int g_data = -1;
	char *tmp_file;
	char tmp[512];
	int g_m = 0;

	for (i = 1; i < argc; i++) {
                if (argv[i][0] == '-') {
                        switch (argv[i][1]) {
			// the number of ancestral populations
                        case 'K':
                                i++;
                                if (argc == i || argv[i][0] == '-')
					print_error_ce("cmd","K (number of ancestral populations)");
                                *K = atoi(argv[i]);
				strcpy(tmp,argv[i]);
                                break;
			// the ploidy
                        case 'm':
                                i++;
                                if (argc == i || argv[i][0] == '-')
					print_error_ce("cmd","m (number of alleles)");
                                *m = atoi(argv[i]);
				g_m = 1;
                                break;
			// help
                        case 'h':  
                                print_help_ce();
                                exit(1);
                                break;
			// licence
                        case 'l': 
                                print_licence_snmf();
                                exit(1);
                                break;
			// genotypic file
                        case 'x':
                                i++;
                                if (argc == i || argv[i][0] == '-')
					print_error_ce("cmd","x (genotype file)");
                                g_data = 0;
                                strcpy(input,argv[i]);
                                break;
			// individual admixture file
                        case 'q':
                                i++;
                                if (argc == i || argv[i][0] == '-')
					print_error_ce("cmd","q (individual admixture coefficients file)");
                                strcpy(input_file_Q,argv[i]);
                                break;
			// ancestral genotype frequency file
                        case 'g':
                                i++;
                                if (argc == i || argv[i][0] == '-')
                                        print_error_ce("cmd","g (ancestral genotype frequencies file)");
                                strcpy(input_file_F,argv[i]);
                                break;
			// genotypic file with masked data
                        case 'i':
                                i++;
                                if (argc == i || argv[i][0] == '-')
                                        print_error_ce("cmd","i (genotype file with masked genotypes)");
                                strcpy(input_file_I,argv[i]);
                                break;
                        default:    print_error_ce("basic",NULL);
                        }
                } else {
                        print_error_ce("basic",NULL);
		}
        }

	// no genotypic file
        if (g_data == -1)
		print_error_ce("option","-x genotype_file");

	// ploidy and negative
        if (g_m && *m <= 0)
                print_error_ce("missing", NULL);

	// negative K
        if (*K <= 0)
		print_error_ce("missing",NULL);

        // write output file names
        tmp_file = remove_ext(input,'.','/');
	if (!strcmp(input_file_F,"")) {
		strcpy(input_file_F,tmp_file);
		strcat(input_file_F,"_I.");
		strcat(input_file_F,tmp);
		strcat(input_file_F,".G");
	}
	if (!strcmp(input_file_Q,"")) {
		strcpy(input_file_Q,tmp_file);
		strcat(input_file_Q,"_I.");
		strcat(input_file_Q,tmp);
		strcat(input_file_Q,".Q");
	}
	if (!strcmp(input_file_I,"")) {
		strcpy(input_file_I,tmp_file);
		strcat(input_file_I,"_I.geno");
	}
	free(tmp_file);

}

