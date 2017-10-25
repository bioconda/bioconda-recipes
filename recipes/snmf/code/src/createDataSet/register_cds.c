/*
    NMF, file: register_cds.c
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
#include "register_cds.h"
#include "print_cds.h"
#include "../sNMF/print_snmf.h"
#include "error_cds.h"
#include "../io/io_tools.h"

// analyse_param_cds

void analyse_param_cds(	int argc, char *argv[], long long* s,
			double *e, char *input, char *output_file) 
{
        int i;
	int g_data = -1;
	int g_e = 0;
	int g_s = 0;

	for (i = 1; i < argc; i++) {
                if (argv[i][0] == '-') {
                        switch (argv[i][1]) {
			// seed
                        case 's':
                                i++;
                                if (argc == i || argv[i][0] == '-')
					print_error_cds("cmd","s (seed number)");
                                *s = atoi(argv[i]);
				g_s = 1;
                                break;
			// percentage of masked genotype
			case 'r':
                                i++;
                                if (argc == i || argv[i][0] == '-')
					print_error_cds("cmd","r (percentage of masked data)");
                                *e = (double) atof(argv[i]);
				if (*e < 0) 
					*e =  0;
				if (*e > 1) 
					*e =  1;
				g_e = 1;
                                break;
			// help
                        case 'h': 
                                print_help_cds();
                                exit(1);
                                break;
			// licence 
                        case 'l':  
                                print_licence_snmf();
                                exit(1);
                                break;
			// input file
                        case 'x':
                                i++;
                                if (argc == i || argv[i][0] == '-')
					print_error_cds("cmd","x (genotype file)");
                                g_data = 0;
                                strcpy(input,argv[i]);
                                break;
			// output file
                        case 'o':
                                i++;
                                if (argc == i || argv[i][0] == '-')
                                        print_error_cds("cmd","o (genotype file with masked genotypes)");
                                strcpy(output_file,argv[i]);
                                break;
                        default:    print_error_cds("basic",NULL);
                        }
                } else {
                        print_error_cds("basic",NULL);
		}
        }

	// no data file
        if (g_data == -1)
		print_error_cds("option","-x genotype_file");

	// no seed
	if (g_s && *s <= 0)
		*s = -1;

	// percentage not in [0,1]
	if (g_e && (*e <= 0 || *e >= 1))
		print_error_cds("missing","");

        // write output file name
	change_ext(input, output_file, "_I.geno");
}

