#' Aquamean
#'
#' @param ENV A data frame with each column as an environmental variable
#' @param quant A numeric vector with 4 quarantines. Default is .01, 0.25, 0.75, 0.99 quantiles.
#' @return A myAquaOut object 1) trap.env - trapezoid shaped environmental variables, 2) env - imputed environmental data, 3) metrics - a data frame with trapezoid parameters for each environmental variable
#' @export
#'
#' @import dplyr
#' @importFrom psych describe
#' @importFrom tibble as_tibble
#' @importFrom rlang .data
#' @import readr
#' @examples
#' x <-which(test_data$occurance==1)
#' ENV<-test_data[x,4:6]
#' aquatrap(ENV, quant = c(.01, 0.25, 0.75, 0.99))
#' myAquaOut <- aquatrap(ENV, quant = c(.01, 0.25, 0.75, 0.99))
aquatrap <- function(ENV, quant = c(.01, 0.25, 0.75, 0.99)) {
  metrics <- describe(as.matrix(ENV),  quant = quant)
  colnames(metrics)[-c(ncol(metrics) - 4:ncol(metrics))] <-
    c('Q1', 'Q2', 'Q3', 'Q4')
  
  metrics <- metrics |>   dplyr::select(min, max, .data$Q1, .data$Q2, .data$Q3, .data$Q4) |>
    as_tibble(rownames = "var") |>  mutate(slope.L = 1 / (.data$Q2 - .data$Q1),
                                           slope.R = 1 / (.data$Q3 - .data$Q4))
  
  trap.ENV <- ENV %>%
    mutate(across(
      everything(),
      ~ case_when(
        . <  metrics[metrics$var ==  cur_column(),]$Q1 ~ 0,
        . <= metrics[metrics$var ==  cur_column(),]$Q2 ~ metrics[metrics$var ==  cur_column(),]$slope.L * (. - metrics[metrics$var ==  cur_column(),]$Q1),
        . <= metrics[metrics$var ==  cur_column(),]$Q3 ~ 1,
        . <= metrics[metrics$var ==  cur_column(),]$Q4 ~ metrics[metrics$var ==  cur_column(),]$slope.R * (. - metrics[metrics$var ==  cur_column(),]$Q4),
        . >  metrics[metrics$var ==  cur_column(),]$Q4 ~ 0
      )
    ))
  
  
  myAquaOut <- list(trap.env = trap.ENV,
                    env = ENV,
                    metrics = metrics)
  return(myAquaOut)
}

