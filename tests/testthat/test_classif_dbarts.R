context("classif.dbarts")

test_that("autotest", {
  learner = LearnerClassifDbarts$new()
  learner$param_set$values = list(ntree = 5L)
  expect_learner(learner)
  result = run_autotest(learner)
  expect_true(result, info = result$error)
})


learner = LearnerClassifDbarts$new()
learner$param_set$values = list(ntree = 5L)

learner

task = tsk("iris")
learner$train(task)
p = lrn$predict(task)
p$confusion
