/*
 *     geno2lfmm, file: main_geno2lfmm.c
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

#include "../convert/geno2lfmm.h"
#include "../convert/register_convert.h"
#include "../io/read.h"

int main (int argc, char *argv[]) {

	int M;	 			// number of SNPs
	int N;				// number of individuals
	char input_file[512];		// input file
	char output_file[512];		// output genotype file

	// analyze command-line
	analyse_param_convert(argc, argv, input_file, output_file, "lfmm");

	// run function
	geno2lfmm(input_file, output_file, &N, &M);

	print_convert(N, M);

	return 0;
}

