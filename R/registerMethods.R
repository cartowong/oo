#' @title Register methods for an object.
#'
#' @description This allows one to use the dollar sign notation to call methods and allows code completion if the IDE supports it.
#'
#' @param  object    the object for which methods are registered.
#' @param methodNames    a character vector of the method names.
#' @return the object with registered methods.
#' @export
registerMethods <- function(object, methodNames) {
  for (methodName in methodNames) {
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
