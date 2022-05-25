library(testthat)
library(aquamean)

#test data
ENV <-test_data[,4:6]

myAquaOut <- aquatrap(ENV, quant = c(.01, 0.25, 0.75, 0.99))
test_that("Checking the aquatrap output object",{
  expect_equal(length(myAquaOut),3)
})
pred_newENV <- aquatrap_pred(ENV, myAquaOut)
test_that("Checking the aquatrap_pred output object",{
  expect_equal(length(pred_newENV),2)
})
