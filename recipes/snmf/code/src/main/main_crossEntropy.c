/*
   crossEntropy, file: main_crossEntropy.c
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

#include <stdlib.h>
#include <string.h>
#include "../sNMF/print_snmf.h"
#include "../crossEntropy/register_ce.h"
#include "../crossEntropy/crossEntropy.h"
#include "../io/io_tools.h"

int main (int argc, char *argv[]) 
{
        //parameters initialization
	char input_file_F[512] = "";	 	// input file for ancestral allele frequencies
	char input_file_Q[512] = "";		// input file for ancestral admixture coefficients
	char input_file_I[512] = "";		// input file with missing data	
	char input_file[512];			// input file "without" missing data 
	int K = 0;
	double all_ce, missing_ce;
	int m = 2;

	// analyse of the command line
	print_head_snmf();
	analyse_param_ce(argc,argv, &m, &K, input_file, input_file_Q, input_file_F, input_file_I);

	// run function
	crossEntropy(input_file, input_file_I, input_file_Q, input_file_F, K, m, &all_ce, &missing_ce);

	return 0;
}

