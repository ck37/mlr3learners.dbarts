#' @title Regression Dbarts Learner
#'
#' @aliases mlr_learners_regr.dbarts
#' @format [R6::R6Class] inheriting from [mlr3::LearnerRegr].
#'
#' @description
#' A [mlr3::LearnerRegr] for a classification dbarts implemented in dbarts::dbarts()] in package \CRANpkg{dbarts}.
#'
# TODO: add references.
# @references
# Breiman, L. (2001).
# Random Forests
# Machine Learning
# \url{https://doi.org/10.1023/A:1010933404324}
#'
#' @export
LearnerRegrDbarts = R6Class("LearnerRegrDbarts", inherit = LearnerRegr, # Adapt the name to your learner. For regression learners inherit = LearnerRegr.
  public = list(
    initialize = function() {
      ps = ParamSet$new( # parameter set using the paradox package
        params = list(
          # These reflect the defaults used by the dbarts package.
          ParamInt$new(id = "ntree", default = 200L, lower = 1L, tags = "train"),
          # Only used for continuous models. Currently untyped to support the NULL default.
          #ParamDbl$new(id = "sigest", default = NULL, lower = 0, tags = "train"),
          ParamUty$new(id = "sigest", default = NULL, tags = "train"),
          # Only used for continuous models
          ParamInt$new(id = "sigdf", default = 3L, lower = 1L, tags = "train"),
          # Only used for continuous models
          ParamDbl$new(id = "sigquant", default = 0.90, lower = 0, upper = 1, tags = "train"),
          ParamDbl$new(id = "k", default = 2.0, lower = 0, tags = "train"),
          ParamDbl$new(id = "power", default = 2.0, lower = 0, tags = "train"),
          ParamDbl$new(id = "base", default = 0.95, lower = 0, tags = "train"),
          # Not applicable for LearnerRegr
          #ParamDbl$new(id = "binaryOffset", default = 0.0, tags = "train"),
          ParamInt$new(id = "ndpost", default = 1000L, lower = 1L, tags = "train"),
          ParamInt$new(id = "nskip", default = 100L, lower = 0L, tags = "train"),
          ParamInt$new(id = "printevery", default = 100L, lower = 0L, tags = "train"),
          ParamInt$new(id = "keepevery", default = 1L, lower = 1L, tags = "train"),
          ParamLgl$new(id = "keeptrainfits", default = TRUE, tags = "train"),
          ParamLgl$new(id = "usequants", default = FALSE, tags = "train"),
          ParamInt$new(id = "numcut", default = 100L, lower = 1L, tags = "train"),
          ParamInt$new(id = "printcutoffs", default = 0, tags = "train"),
          ParamLgl$new(id = "verbose", default = TRUE, tags = "train"),
          ParamLgl$new(id = "keeptrees", default = FALSE, tags = "train"),
          ParamLgl$new(id = "keepcall", default = TRUE, tags = "train"),
          ParamLgl$new(id = "sampleronly", default = FALSE, tags = "train"),
          ParamLgl$new(id = "offset.test", default = FALSE, tags = "predict")
        )
      )
      # Override package defaults.
      # We need keeptrees to be true in order to predict().
      ps$values = list(keeptrees = TRUE)

      super$initialize(
        # see the mlr3book for a description: https://mlr3book.mlr-org.com/extending-mlr3.html
        id = "regr.dbarts",
        packages = "dbarts",
        feature_types = c("integer", "numeric", "factor", "ordered"),
        # TODO: add "se" to the list of predict types.
        predict_types = c("response"),
        param_set = ps,
        # TODO: add importance.
        # Parallel is giving an autotest error.
        properties = c("weights")#, "parallel")
      )
    },

    train_internal = function(task) {
      pars = self$param_set$get_values(tags = "train")

      # Extact just the features from the task data.
      data = task$data(cols = task$feature_names)

      # Convert from data.table to normal data.frame, just to be safe.
      # Dbarts expects x.train to be a dataframe.
      setDF(data)

      # This will also extract a data.table
      outcome = task$data(cols = task$target_names)
      setDF(outcome)
      # Outcome will now be a factor vector.
      outcome = outcome[[1]]

      if ("weights" %in% task$properties) {
        pars$weights = task$weights$weight
      }

      # Use the mlr3misc::invoke function (it's similar to do.call())
      # y.train should either be a binary factor or have values {0, 1}
      invoke(dbarts::bart, x.train = data, y.train = outcome,
             .args = pars)
    },

    predict_internal = function(task) {
      pars = self$param_set$get_values(tags = "predict") # get parameters with tag "predict"


      newdata = task$data(cols = task$feature_names) # get newdata
      #type = ifelse(self$predict_type == "response", "response", "prob") # this is for the randomForest package

      # Other possible vars: offset.test, combineChains, ...
      setDF(newdata)

      # This will return a matrix of predictions, where each column is an observation
      # and each row is a sample from the posterior.
      p = invoke(predict, self$model, test = newdata, .args = pars)

      # Transform predictions.
      # TODO: confirm that this is the correct element name.
      pred = colMeans(p)

      mlr3::PredictionRegr$new(task = task)
    }

    # Add method for importance, if learner supports that.
    # It must return a sorted (decreasing) numerical, named vector.
    # TODO later.
    # importance = function() { }
  )
)
