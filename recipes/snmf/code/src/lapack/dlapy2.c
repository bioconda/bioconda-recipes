#include "blaswrap.h"
#include "f2c.h"

doublereal dlapy2_(doublereal *x, doublereal *y)
{
/*  -- LAPACK auxiliary routine (version 3.1) --   
       Univ. of Tennessee, Univ. of California Berkeley and NAG Ltd..   
       November 2006   


    Purpose   
    =======   

    DLAPY2 returns sqrt(x**2+y**2), taking care not to cause unnecessary   
    overflow.   

    Arguments   
    =========   

    X       (input) DOUBLE PRECISION   
    Y       (input) DOUBLE PRECISION   
            X and Y specify the values x and y.   

    ===================================================================== */
    /* System generated locals */
    doublereal ret_val, d__1;
    /* Builtin functions */
    double sqrt(doublereal);
    /* Local variables */
    static doublereal w, z__, xabs, yabs;



    xabs = abs(*x);
    yabs = abs(*y);
    w = max(xabs,yabs);
    z__ = min(xabs,yabs);
    if (z__ == 0.) {
	ret_val = w;
    } else {
/* Computing 2nd power */
	d__1 = z__ / w;
	ret_val = w * sqrt(d__1 * d__1 + 1.);
    }
    return ret_val;

/*     End of DLAPY2 */

} /* dlapy2_ */
