/*
    sNMF, file: main_sNMF.c
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
#include <time.h>
#include "../sNMF/sNMF.h"
#include "../sNMF/register_snmf.h"
#include "../sNMF/print_snmf.h"
#include "../io/io_tools.h"

int main (int argc, char *argv[]) {
	
	// parameters allocation
	sNMF_param param = (sNMF_param) calloc(1, sizeof(snmf_param));

	//parameters initialization
	init_param_snmf(param);

	// print
	print_head_snmf();
	print_options(argc, argv);

	// analyse of the command line and fill param
	analyse_param_snmf(argc,argv, param); 

	// run function
	sNMF(param); 

	// free memory
	free_param_snmf(param);
	free(param);

	return 0;
}
