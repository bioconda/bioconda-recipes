/**
 * @addtogroup convert
 * @{
 * @file convert.h
 * @brief group of functions for conversion from the  
 * ancestrymap, geno, lfmm, vcf, ped formats to the lfmm and geno formats.
 * 
 * The formats are described here, http://membres-timc.imag.fr/Olivier.Francois/LEA/tutorial.htm. 
 * The principal function names are input2output, where input is the input data format 
 * (ancestrymap, geno, lfmm, vcf or ped) and output is the output data format (lfmm or geno).
 * 
 * The input2output function also output the number of lines and the number of columns or the 
 * number of individual and the number of loci (it depends on the format)
 * 
 * \warning The variables N, M, L, n, can be the number of lines, columns, individuals or loci
 * depending on the data format.
 *
 * TODO: 
 * - There is no function vcf2lfmm (It can be done with vcf2geno and geno2lfmm).
 * - The vcf format output SNP info  
 * @}
 */
