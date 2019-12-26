helper = list.files(system.file("testthat", package = "mlr3"), pattern = "^helper.*\\.[rR]", full.names = TRUE)
ok = lapply(helper, source)

context("regr.dbarts")

test_that("autotest", {
  learner = LearnerRegrDbarts$new()

  learner$param_set$values = c(
    learner$param_set$values,
    ntree = 5L)

  expect_learner(learner)
  result = run_autotest(learner)
  expect_true(result, info = result$error)
})

if (FALSE) {

  learner = LearnerClassifDbarts$new()
  learner$param_set$values = c(
    learner$param_set$values,
    ntree = 5L)

  tsk()
  task = tsk("spam")
  task

  tasks = generate_tasks(learner)


  # Sanity checks are not passing correctly.
  # TODO : get this resolved.
  tasks$sanity

  learner$train(tasks$sanity_switched)
  pred = learner$predict(tasks$sanity_switched)

  pred

  tasks$sanity_switched


  learner$train(tasks$sanity)
  pred = learner$predict(tasks$sanity)
  pred

  # Check for missing data.
  colSums(is.na(task$data()))
  learner$train(task)
  # TODO: fix prediction.
  p = learner$predict(task)
  p$confusion

  library(data.table)
  data = task$data(cols = task$feature_names)
  setDF(data)

  data = na.omit(data)
  dim(data)

  outcome = as.vector(task$data(cols = task$target_names))
  setDF(outcome)
  outcome = outcome[[1]]

  res = dbarts::bart(x.train = data, y.train = outcome, x.test = data, keeptrees = TRUE)

  names(res)

  dim(res$yhat.test)

  preds = predict(res, data)
  preds
  dim(preds)
  colMeans(preds)

}
