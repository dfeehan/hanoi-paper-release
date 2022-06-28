//
// Random degree model with probe group estimation for Hanoi paper
// added hidden populations
//

data {
  // the size of the entire population (not the sample)
  real<lower=0> N;
  
  // the size of the sample
  int<lower=0> n;
  
  // the number of probe groups
  int<lower=0> G;
  
  // the number of hidden groups
  // (can be set to 0, if there are no hidden groups)
  int<lower=0> K;
  
  // reported membership in groups
  int<lower=0> tot_Z[G];
  
  // reported connections to groups (the ARD)
  int<lower=0> Y[n,G];
  
  // reported connections to hidden groups (also ARD)
  int<lower=0> X[n,K];
  
}
parameters {
  
  // the prevalence of the probe groups
  vector<lower=0,upper=1>[G] p_g;
  
  // the prevalence of the hidden groups
  vector<lower=0,upper=1>[K] p_k;
  
  // the mean and variance of the log-degree distribution
  // NB: be sure the constraints are right here - this can cause
  //     bugs if they are not!
  real<lower=1,upper=8> mu;
  real<lower=0.25,upper=2> sigma; 
  
  // the degree for each survey respondent
  // note that, under this model, the degree is not discrete - so it might
  // be more accurate to think about it as an expected degree
  vector<lower=0>[n] d;
  
}

model {
  
  // priors on probe group prevalences: uniform on (0,1)
  // NB: if these are changed, be sure to change constraints on parameters too
  p_g ~ uniform(0,1);
  
  // priors on hidden population prevalences: uniform on (0,1)
  // NB: if these are changed, be sure to change constraints on parameters too
  if(K > 0) {
    p_k ~ uniform(0,1);
  }
  
  ////////////
  // Log-Normal degrees
  // NB: these priors are on the log scale
  // NB: if these are changed, be sure to change constraints on parameters too
  mu ~ uniform(1,8);
  sigma ~ uniform(0.25,2);
  
  d ~ lognormal(mu, sigma);
  
  // model for respondents' group memberships, given Nk's
  for(g in 1:G) {
    tot_Z[g] ~ binomial(n, p_g[g]);
  }
  
  // model for probe group ARD
  for(g in 1:G) {
    
      //////////////
      // Poisson model
      Y[,g] ~ poisson(d * p_g[g]);
      
  } 
  
  // model for hidden group ARD
  if(K > 0) {
    for(k in 1:K) {
      
        //////////////
        // Poisson model
        X[,k] ~ poisson(d * p_k[k]);
        
    }
  }
  
}

generated quantities {
  real<lower=0> mean_degree;
  real<lower=0> var_degree;
  
  // this is the mean and variance of the log-normal degree distribution
  mean_degree = exp(mu + (sigma^2)/2);
  var_degree = exp((sigma^2) - 1) * exp(2*mu + sigma^2);
}



