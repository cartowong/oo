#' Finalize an object.
#'
#' This function should be called at the end of a constructor function to finalize an object.
#'
#' @param object an object
#' @param publicMethodNames a character vector of all public method names
#' @details See http://www.github.com/cartowong/oo.
#' @export
finalizeObject <- function(object, publicMethodNames) {
  # remove private getter and setter
  object$getPrivate <- NULL
  object$setPrivate <- NULL

  for (methodName in publicMethodNames) {
    if (!(methodName %in% object$ls())) {
      stop(sprintf('Registering a non-existing method %s', methodName))
    }

    # use immediate function to create a unique environment for each method
    object[[methodName]] <- (function(object, methodName) {

      # make sure the function below can resolve these symbols at runtime
      object <- object
      methodName <- methodName

      # Since the method may be overriden after it is registered, we obtain the method from the
      # object's local environment.
      function(...) {
        method <- object$get(methodName)
        method(...)
      }
    })(object, methodName)
  }
  object
}
