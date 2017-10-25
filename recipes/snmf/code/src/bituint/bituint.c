/*
   bituint, file: bituint.c
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
#include <math.h>
#include "bituint.h"

// init_mat

void init_mat_bituint(bituint** dat, int N, int Mc, int *Mp)
{
	*Mp = ceil(((double)Mc)/ SIZEUINT);
	*dat = (bituint *) calloc(N*(*Mp),sizeof(bituint));
}

