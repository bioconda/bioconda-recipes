/*
    convert, file: register_convert.c
    Copyright (C) 2012 Eric Frichot

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
#include "register_convert.h"
#include "../io/io_tools.h"

// analyse_param_convert

void analyse_param_convert (int argc, char *argv[], char *input, char *output, char *type)
{
	char* tmp_file;

	// test the number of args and save the args
	if (argc == 2) {
		// input file
		strcpy(input, argv[1]);
		// output file
	        tmp_file = remove_ext(input,'.','/');
                strcpy(output, tmp_file);
                strcat(output,".");
                strcat(output,type);
		free(tmp_file);
	} else if (argc != 3) {
		printf("ERROR: commmand line format incorrect.\n\n"
		"HELP: %s input_file [output_file]\n",argv[0]);
                exit(1);
	} else {
		// input file
		strcpy(input, argv[1]);
		// output file
		strcpy(output, argv[2]);
	}

	// print command line summary
        printf("Summary of the options:\n\n"
               "        -input file      %s\n"
               "        -output file     %s\n", input, output);
	
}

void print_convert(int N, int M)
{
        printf("\n\t- number of detected individuals:\t%d\n",N);
        printf("\t- number of detected loci:\t\t%d\n\n",M);
}
