fit_stan_model_to_survey <- function(school,
                                     sampled.row.idx,
                                     gp.set,
                                     sample.size,
                                     gp.set.idx,
                                     svy.index,
                                     model,
                                     model_out_dir,
                                     estimate_probegp_size, # should be TRUE/FALSE
                                     warmup=2000,
                                     iter=10000,
                                     chains=4,
                                     refresh = max(iter/10, 1),
                                     prog = TRUE,
                                     # NB: save_fit = TRUE saves all samples from each fit,
                                     # but creates files that use a *lot* of disk space
                                     # (in the nbhd of 30 - 100 GB, depending on number if iterations, etc)
                                     save_fit = FALSE,
                                     ...) {
  
  
  
  ############
  ## grab data for this popn and survey
  cur.census <- nr.censuses[[school]]
  cur.popn.size <- nrow(cur.census)
  
  cur.sampled.rows <- unlist(sampled.row.idx)

  
  if (prog) {
    cat(glue::glue("
                   Starting {school}, svy.index={svy.index}
                   
                   ")) 
  }
    
  # NB: it's important that cur.vars and cur.y.cols be in the same order
  cur.ego.vars <- unlist(gp.set)
  cur.y.vars <- paste0('y.', cur.ego.vars)
  
  cur.vars <- c(cur.ego.vars, cur.y.vars)
  
  cur.svy <- cur.census %>%
    select_at(c('id', 'degree', all_of(cur.vars)) %>%
    # grab the relevant rows
    slice(purrr::simplify(cur.sampled.rows)) %>%
    # NB: arrange rows by id
    arrange(id) %>% 
    # weight is one over prob inclusion
    mutate(weight = cur.popn.size / sample.size) %>% 
    mutate(y.all.gps = rowSums(.[cur.y.vars]))
  
  # true size of probe groups
  cur.true.probegp.size <- cur.census %>% 
    summarise_at(all_of(cur.ego.vars), sum) %>%
    select(all_of(cur.ego.vars))
  
  ############
  ## prep data for model
  
  # number of groups
  cur.G <- length(cur.ego.vars)
  # matrix whose entry (i,j) is an indicator for whether or not $i$ reports being in group $j$
  cur.ego.var.matrix <- cur.svy %>% 
    # NB: cur.svy's rows are arranged by id above
    select(cur.ego.vars)
  cur.ego.sums <- cur.ego.var.matrix %>% colSums()
  
  # matrix whose entry (i,j) contains the number of connections to 
  # group $j$ reported by ego $i$
  cur.ard.reports <- cur.svy %>% 
    # NB: cur.svy's rows are arranged by id above
    select(all_of(cur.y.vars))
  
  cur.sample.size <- nrow(cur.svy)
  
  data_for_model <-
    list(
      # ARD
      Y = cur.ard.reports,
      # number of probe gps
      G = cur.G,
      # we have no hidden popns here, so this is 0
      K = 0,
      # dummy input for X
      # see
      # https://discourse.mc-stan.org/t/passing-matrix-with-one-dimension-equal-to-0-works-only-sometimes/11732
      X = matrix(0, nrow=cur.sample.size, ncol=0),
      # size of entire popn
      N = cur.popn.size,
      # size of survey sample
      # (assumed for now to be SI sample)
      n = cur.sample.size)
  
  if(estimate_probegp_size) {
    data_for_model <- c(data_for_model,
                        # respondent probe gp membership
                        tot_Z = list(cur.ego.sums))
  } else {
    data_for_model <- c(data_for_model,
                        # ... instead of respondent probe gp
                        #     membership, need true probe gp sizes
                        p_g = list(as.numeric(cur.true.probegp.size) / cur.popn.size))
  }

  ############
  ## sample from model
  model_fit <- sampling(model,
                        data = data_for_model,
                        warmup = warmup,
                        iter = iter,
                        chains = chains,
                        refresh = refresh)
  
  fit_summ <- rstan::summary(model_fit)
  
  # get posterior params for degree distn
  mu_median <- model_fit %>% 
    spread_draws(mu) %>%
    median_qi(mu)
  
  sigma_median <- model_fit %>% 
    spread_draws(sigma) %>%
    median_qi(sigma)
  
  # get posterior estimates of average degree 
  mean_degree_median <- model_fit %>% 
    spread_draws(mean_degree) %>%
    median_qi(mean_degree)
  
  # get posterior estimates of variance in degree 
  var_degree_median <- model_fit %>% 
    spread_draws(var_degree) %>%
    median_qi(var_degree)
  
  # get posterior median individual degrees
  d_median <- model_fit %>% 
    spread_draws(d[rownum]) %>%
    median_qi(d)
  
  if (estimate_probegp_size) {
    # get posterior probe group size estimates 
    p_median <- model_fit %>% 
      spread_draws(p_g[rownum]) %>%
      median_qi(p_g)
  }
  
  res <- list(school=school,
              gp.set.idx = gp.set.idx,
              svy.index = svy.index,
              sampled.row.idx=sampled.row.idx,
              gp.set=gp.set,
              sample.size=sample.size,
              fit_summ = fit_summ,               
              model_data = data_for_model,
              post_mu_median = mu_median,
              post_sigma_median = sigma_median,
              post_mean_degree_median = mean_degree_median,
              post_var_degree_median = var_degree_median,
              post_d_median = d_median)
  
  if(estimate_probegp_size) {
    res <- c(res,
             post_p_median = list(p_median))
  }
  
  if(save_fit) {
    res_fn <- glue::glue("{school}_{gp.set.idx}_{svy.index}_stanfit.rds")
    
    # add the stanfit object (which will be big)
    ressave <- c(res,
                 fit = list(model_fit))
    
    saveRDS(ressave,
            file=file.path(model_out_dir, res_fn))  
  }
  
  # return everything except for the stanfit object
  # (if you want the stanfit object, use save_fit)
  return(res)
}