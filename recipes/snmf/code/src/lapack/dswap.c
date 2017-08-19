
/*  -- translated by f2c (version 19940927).
   You must link the resulting object file with the libraries:
	-lf2c -lm   (in that order)
*/

#include "f2c.h"

/* Subroutine */ int dswap_(integer *n, doublereal *dx, integer *incx, 
	doublereal *dy, integer *incy)
{


    /* System generated locals */
    //integer i__1;

    /* Local variables */
    static integer i, m;
    static doublereal dtemp;
    static integer ix, iy, mp1;


/*     interchanges two vectors.   
       uses unrolled loops for increments equal one.   
       jack dongarra, linpack, 3/11/78.   
       modified 12/3/93, array(1) declarations changed to array(*)   


    
   Parameter adjustments   
       Function Body */
#define DY(I) dy[(I)-1]
#define DX(I) dx[(I)-1]


    if (*n <= 0) {
	return 0;
    }
    if (*incx == 1 && *incy == 1) {
	goto L20;
    }

/*       code for unequal increments or equal increments not equal   
           to 1 */

    ix = 1;
    iy = 1;
    if (*incx < 0) {
	ix = (-(*n) + 1) * *incx + 1;
    }
    if (*incy < 0) {
	iy = (-(*n) + 1) * *incy + 1;
    }
    //i__1 = *n;
    for (i = 1; i <= *n; ++i) {
	dtemp = DX(ix);
	DX(ix) = DY(iy);
	DY(iy) = dtemp;
	ix += *incx;
	iy += *incy;
/* L10: */
    }
    return 0;

/*       code for both increments equal to 1   


         clean-up loop */

L20:
    m = *n % 3;
    if (m == 0) {
	goto L40;
    }
    //i__1 = m;
    for (i = 1; i <= m; ++i) {
	dtemp = DX(i);
	DX(i) = DY(i);
	DY(i) = dtemp;
/* L30: */
    }
    if (*n < 3) {
	return 0;
    }
L40:
    mp1 = m + 1;
    //i__1 = *n;
    for (i = mp1; i <= *n; i += 3) {
	dtemp = DX(i);
	DX(i) = DY(i);
	DY(i) = dtemp;
	dtemp = DX(i + 1);
	DX(i + 1) = DY(i + 1);
	DY(i + 1) = dtemp;
	dtemp = DX(i + 2);
	DX(i + 2) = DY(i + 2);
	DY(i + 2) = dtemp;
/* L50: */
    }
    return 0;
} /* dswap_ */


