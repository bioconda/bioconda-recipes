/*
   createDataSet, file: main_createDataSet.c
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

#include <string.h>
#include <stdlib.h>
#include "../createDataSet/createDataSet.h"
#include "../createDataSet/register_cds.h"
#include "../sNMF/print_snmf.h"
#include "../io/io_tools.h"

int main (int argc, char *argv[]) {

	// local parameters
	char input_file[512];		// input file "without" missing data
	char output_file[512] = "";	// output file with missing data
	double e = 0.05;		// output percentage of missing data
	long long seed = -1;
	
	// analyse of the command line
        print_head_snmf();
	analyse_param_cds(argc, argv, &seed, &e, input_file, output_file);

	// run function
        createDataSet(input_file, (long long) seed, e, output_file);

	return 0;
}

