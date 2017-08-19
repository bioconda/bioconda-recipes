/*
    createDataSet, file: print_cds.c
    Copyright (C) 2013 Eric Frichot

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


#include "print_cds.h"
#include <stdio.h>
#include <stdlib.h>

// print_help

void print_help_cds() 
{
   printf("\nHELP: ./createDataSet options \n\n"
         "mandatory:\n"
         "        -x input_file         -- genotype file (in .geno format)\n\n"

         "optional:\n"
         "        -h                    -- help\n"
         "        -s seed               -- seed random init             (default: random)\n"
         "        -r percentage         -- percentage of masked data    (default: 0.05)\n\n"
         "        -o output_file        -- output file (in .geno format)(default: input_file_I.geno)\n\n"
        );
}

// print_summary

void print_summary_cds (int N, int M, long long seed, double e, char *input, char *output) 
{

           printf("summary of the options:\n\n"
                "        -n (number of individuals)                 %d\n"  
                "        -L (number of loci)                        %d\n"
                "        -s (seed random init)                      %lu\n"
                "        -r (percentage of masked data)             %G\n"
                "        -x (genotype file in .geno format)         %s\n"
                "        -o (output file in .geno format)           %s\n"
                , N, M, (unsigned long)seed, e, input, output);
}

