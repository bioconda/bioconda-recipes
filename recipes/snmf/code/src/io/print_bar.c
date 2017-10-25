/*
   LFMM, file: print_bar.c
   Copyriht (C) 2012 Eric Frichot

   This proram is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This proram is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   alon with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "print_bar.h"
#include <stdio.h>
#include <stdlib.h>

// init_bar

void init_bar(int *i, int *j)
{
	int n;
	*i = 0;
	*j = 0;
	printf("\t[");
	for (n = 0; n < 75; n++)
		printf(" ");
	printf("]\n\t[");
	
}

// print_bar

void print_bar(int *i, int *j, int Niter)
{
	int shell_size = 75;
	int nb = (((*j)+1) * shell_size) / Niter;

	(*j) ++;
	while (*i < nb) { 
		(*i) ++;
		printf("=");
	}
	fflush(stdout);
}

// final bar

void final_bar()
{
	printf("]\n");
}
