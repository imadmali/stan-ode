functions {
  real[] ode_sys(real t, real[] y, real[] theta, real[] x, int[] x_int) {
    #include "user_func.stan"
  }
}
data {
  int<lower=0,upper=1> sampling;
  int<lower=0> N;
  int<lower=0> K;
  int<lower=1> T;
  real y0[N];
  real t0[1];
  real ts[T];
  real y[T,N];
}
transformed data {
  real x[0];
  int x_int[0];
}
parameters {
  #include "user_parameters.stan"
}
model {
  real y_hat[T,N];
  y_hat = integrate_ode_rk45(ode_sys, y0, t0[1], ts, theta, x, x_int);
  #include "user_model.stan"
}
generated quantities {}
