/*
   io, file: io_error.c
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
#include "io_error.h"

// test_column

void test_column(char *file, FILE *m_File, int i, int j, int N, char *token)
{
	// if not enough columns
	if (i != N) {
		printf("Error: unable to read file %s. It seems that"
				" line %d contains %d columns instead of %d" 
				" (number of columns of line 1)."
				"\n\n", file, j, i, N);
		fclose(m_File);
		exit(1);
	}

	// if too many lines
	if (token && *token != '\n' && *token != EOF) {
		printf("Error: unable to read file %s. It seems that"
				" line %d contains more than %d columns" 
				" (number of columns of line 1).\n\n",
				file, j, N);
		fclose(m_File);
		exit(1);
	}
}

// test_line

void test_line(char *file, FILE *m_File, int i, int N)
{
        // if a file contains not enough lines
        if (i != N) {
                printf("Error: unable to read file %s. It seems that it "
                                "contains %d lines instead of %d.\n\n", file,
                                i, N);
                fclose(m_File);
                exit(1);
        }
        // if a file contains too many lines
        if (!feof(m_File)) {
                printf("Error: unable to read file %s. It seems that it "
                                "contains more than %d lines.\n\n", file, N);
                fclose(m_File);
                exit(1);
        }
}
