#!/bin/bash -e

TMPFILE=$(mktemp tmp.XXXXXXXXXX)
mv ${TMPFILE} ${TMPFILE}.c
TMPFILE=${TMPFILE}.c

cleanup() {
    rm a.out $TMPFILE
}

trap cleanup INT TERM

cat <<'EOF'>$TMPFILE
#include <stdio.h>
#include <gsl/gsl_errno.h>
#include <gsl/gsl_matrix.h>
#include <gsl/gsl_odeiv2.h>
#include <gsl/gsl_pow_int.h>

#define NY 2
#define STR_EVALUATE(x)   #x
#define STRINGIFY(x)      STR_EVALUATE(x)

#define PRECISION %.9e


int
func (double t, const double y[], double f[], void * params)
{
  double mu = *(double *) params;
  f[0] =  y[1];
  f[1] = -y[0] + mu*y[1]*(1-gsl_pow_2(y[0]));
  return GSL_SUCCESS;
}


int
jac (double t, const double y[], double *dfdy, double dfdt[], void *params)
{
  double mu = *(double *) params;
  gsl_matrix_view dfdy_mat = gsl_matrix_view_array(dfdy, NY, NY);
  gsl_matrix *m = &dfdy_mat.matrix;

  gsl_matrix_set (m, 0, 1, 1.0);
  gsl_matrix_set (m, 1, 0, -1.0 - 2.0*mu*y[0]*y[1]);
  gsl_matrix_set (m, 1, 1, mu*(1.0 - gsl_pow_2(y[0])));

  dfdt[0] = 0.0;
  dfdt[1] = 0.0;

  return GSL_SUCCESS;
}

int
integrate_ode_using_driver (double t, double t1, double y[], int n_steps,
			    double h_init, double h_max, double eps_abs,
			    double eps_rel, void *params, int print_values)
{
  int i; // Counter in macro-step loop
  int j; // Counter in print loop
  int status;
  size_t dim = NY;
  double ti;
  double dt = (t1-t)/(double)n_steps;
  const gsl_odeiv2_step_type * T = gsl_odeiv2_step_msbdf;
  gsl_odeiv2_step * s = gsl_odeiv2_step_alloc (T, dim);

  gsl_odeiv2_system sys = {func, jac, dim, params};

  gsl_odeiv2_driver * d = gsl_odeiv2_driver_alloc_y_new(&sys, gsl_odeiv2_step_msbdf, h_init, eps_abs, eps_rel);
  gsl_odeiv2_step_set_driver(s, d);

  if (h_max > 0.0)
    {
      gsl_odeiv2_driver_set_hmax(d, h_max);
    }

  for (i = 0; i < n_steps; ++i)
    {
      // Macro-step loop
      ti = t + dt*(i+1);
      status = gsl_odeiv2_driver_apply (d, &t, ti, y);

      if (status != GSL_SUCCESS)
	{
	  printf ("error, return value=%d\n", status);
	  break;
	}
      if (print_values)
	{
	  printf(STRINGIFY(PRECISION), t);
	  for (j = 0; j < NY; ++j)
	    {
	      printf(" " STRINGIFY(PRECISION), y[j]);
	    }
	  printf("\n");
	}

    }

  gsl_odeiv2_driver_free (d);
  gsl_odeiv2_step_free (s);

  return status;
}



int
main (void)
{
  int status;
  double	mu	    = 10;
  double	t	    = 0.0;
  double	t1	    = 100.0;
  double        y[2]	    = {1.0, 0.0};
  int           n_steps     = 50;
  double	h_init	    = 1e-6;
  double	eps_abs	    = 1e-6;
  double	eps_rel	    = 1e-6;

  int		print_values = 1;


  status = integrate_ode_using_driver(t, t1, y, n_steps, h_init, 0.0, eps_abs, eps_rel, &mu, print_values);

  if (status == GSL_SUCCESS)
    {
      return 0;
    }

  return 1;

}
EOF

if [[ $(uname -s) == Darwin ]]; then
  RPATH="-Xlinker -rpath -Xlinker ${PREFIX}/lib"
fi

${CC:-gcc} -I${PREFIX}/include -L${PREFIX}/lib $TMPFILE -lgsl -lgslcblas -lm $RPATH
./a.out >/dev/null

cleanup
