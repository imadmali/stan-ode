# extract and clean ode equations in user defined function
clean_f <- function(obj) {
  separate <- deparse(body(obj), width.cutoff = 500)
  separate <- gsub("[[:space:]]", "", separate)
  equations <- separate[-grep("[{}]", separate)]
  return_sel <- grep("return", equations)
  if (length(return_sel)==0)
    return(equations)
  else
    return(equations[-return_sel])
}

# cleanup assignment operator
clean_operator <- function(eqn) {
  n_eqn <- length(eqn)
  out <- NULL
  for (i in 1:n_eqn)
    out[i] <- gsub("<-", "=", eqn[i])
  return(out)
}

# get the derivatives with respect to time as defined by the user
get_lhs <- function(eqn) {
  eqn_split <- strsplit(eqn, "=")
  lhs <- sapply(eqn_split, "[[", 1)
  return(lhs)
}


# translate state and parameter variables from R to Stan
trans_vars <- function(eqn, map) {
  n_eqn <- length(eqn)
  out <- NULL
  for (i in 1:n_eqn) {
    eqn_trim <- trim(eqn[i])
    out[i] <- paste0(swap(eqn_trim, map), collapse = "")
  } 
  return(out)
}

# replace lhs, state, and pars with the stan appropriate values
swap <- function(eqn_trim, map) {
  n_eqn_line <- length(eqn_trim)
  for (i in 1:n_eqn_line) {
    clean_val <- gsub("[[:punct:]]", "", eqn_trim[i])
    sel_lhs <- which(map$lhs[,"user"] == clean_val)
    sel_state <- which(map$state[,"user"] == clean_val)
    sel_pars <- which(map$pars[,"user"] == clean_val)
    if (length(sel_lhs) > 0)
      eqn_trim[i] <- gsub(clean_val, map$lhs[sel_lhs, "stan"], eqn_trim[i])
    if (length(sel_state) > 0)
      eqn_trim[i] <- gsub(clean_val, map$state[sel_state, "stan"], eqn_trim[i])
    if (length(sel_pars) > 0)
      eqn_trim[i] <- gsub(clean_val, map$pars[sel_pars, "stan"], eqn_trim[i])
  }
  return(eqn_trim)
}

# split the equation at each operator (keeping the operator)
trim <- function(eqn_line) {
  out <- unlist(strsplit(eqn_line, "(?<=[[:punct:]])", perl=TRUE))
  return(out)
}