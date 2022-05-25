#' A function to predict the TSI index to a new set (or future) environemntal variables
#'
#' @param ENV_new A set of new environmental data to be used for prediction
#' @param myAquaOut  output of aquatrap function 
#' @param na.rm A logical indicating whether missing values should be removed when calculating the niche. Default is FALSE
#'
#' @return a list object with 2 elements: trap.env - a trapeze environmental variables and yul- HSI index (probability of occurance)
#' @export
#' 
#' @import dplyr
#' @importFrom rlang .data
#' @import readr
#' @examples
#' x <- which(test_data$occurance==1)
#' ENV<-test_data[x , 4:6]
#' myAquaOut <- aquatrap(ENV, quant = c(.01, 0.25, 0.75, 0.99))
#' ENVnew<-test_data[ ,4:6]
#' prde_newENV <- aquatrap_pred(ENVnew, myAquaOut)
aquatrap_pred <- function(ENV_new, myAquaOut,  na.rm = FALSE) {
  metrics = myAquaOut$metrics
  trap.ENV <- ENV_new %>% 
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
  
  
  yul = rowMeans(trap.ENV, na.rm = na.rm)
  return(list(trap.env = trap.ENV,
              yul = yul))
}

