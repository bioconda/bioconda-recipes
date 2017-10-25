/*
    LFMM, file: io_tools.c
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
#include "io_tools.h"
#include "read.h"
#include "../matrix/error_matrix.h"

// change_ext

void change_ext(char *input, char *output, char *ext)
{
        char *tmp_file;

        if (!strcmp(output, "")) {
        	tmp_file = remove_ext(input,'.','/');
                strcpy(output, tmp_file);
                strcat(output, ext);
        	free(tmp_file);
        }
}

// remove_ext (from stackoverflow)

char* remove_ext (char* mystr, char dot, char sep) 
{
        char *retstr, *lastdot, *lastsep;

        // Error checks and allocate string.
        if (mystr == NULL)
                return NULL;

        if ((retstr = malloc (strlen (mystr) + 1 * 1)) == NULL)
                return NULL;

        // Make a copy and find the relevant characters.
        strcpy (retstr, mystr);
        lastdot = strrchr (retstr, dot);
        lastsep = (sep == 0) ? NULL : strrchr (retstr, sep);

        // If it has an extension separator.
        if (lastdot != NULL) {
                // and it's before the extenstion separator.

                if (lastsep != NULL) {
                        if (lastsep < lastdot) {
                                // then remove it.
                                *lastdot = '\0';
                        }
                } else {
                        // Has extension separator with no path separator.
                        *lastdot = '\0';
                }
        }

        // Return the modified string.
        return retstr;
}

// nb_cols_geno

int nb_cols_geno (char *file)
{
        FILE *fp = fopen_read(file);
        int cols = 0;
        int c;

	// count the number of elements until EOF or "\n"
        c = fgetc(fp);
        while ((c != EOF) && (c != 10)) {
                cols++;
                c = fgetc(fp);
        }

        fclose(fp);

        return cols;
}

// nb_cols_lfmm

int nb_cols_lfmm (char *file)
{
        FILE *fp = fopen_read(file);
        int cols = 0;
        int c;
        char* szbuff; 
        char* token;

        c = fgetc(fp);
        while ((c != EOF) && (c != 10)) {
		// count only columns (no space or tab)
        	c = fgetc(fp);
                cols++;
        }

        fclose(fp);

	// open file
	fp = fopen_read(file);
        szbuff = (char *) calloc(2* cols, sizeof(char));
	// read first line
        token = fgets(szbuff,2 * cols, fp);
	cols = 0;
	// count for first line
	token = strtok(szbuff, SEP);
	while (token) {
		cols++;
		token = strtok(NULL, SEP);
	}
	
	fclose(fp);
	free(szbuff);

        return cols;
}

// nb_lines

int nb_lines (char *file, int M)
{
        FILE *fp = fopen_read(file);
        int lines = 0;
        int max_char_per_line = 20 * M + 10;
        char* szbuff = (char *) calloc(max_char_per_line, sizeof(char));

	// while not end of file
	while (fgets(szbuff,max_char_per_line,fp))
		// count
		lines++;

        fclose(fp);
        free(szbuff);

        return lines;
}

// fopen_read

FILE* fopen_read (char *file_data)
{
        FILE *m_File = fopen(file_data, "r");
        if (!m_File)
                print_error_global("open", file_data, 0);

	return m_File;
}

// fopen_write

FILE* fopen_write (char *file_data)
{
        FILE *m_File = fopen(file_data, "w");
        if (!m_File)
                print_error_global("open", file_data, 0);

	return m_File;
}

// print_options

void print_options(int argc, char *argv[]) {

        int i;

        for (i=0;i<argc;i++)
                printf("%s ",argv[i]);

        printf("\n");
}
