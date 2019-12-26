# mlr3learners.dbarts

[![Build Status](https://travis-ci.org/ck37/mlr3learners.dbarts.svg?branch=master)](https://travis-ci.org/ck37/mlr3learners.dbarts)

This packages provides a template for adding new learners for [mlr3](https://mlr3.mlr-org.com).

## Test Your Learner
If you run `devtools::load_all()` the function `run_autotest()` is available in your global environment.
The autotest query the learner for its properties to create a custom test suite of tasks for it.
Make sure that **at least** the following is executed in the unit test `tests/testthat/test_classif_your_learner.R` (adept names to your learner):

```r
learner = LearnerClassifRanger$new()
expect_learner(learner)
result = run_autotest(learner)
expect_true(result, info = result$error)
```

## Check your package
If this runs, your learner should be fine:
```r
devtools::check()
```
