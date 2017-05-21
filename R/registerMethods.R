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

    object[[methodName]] <- (function(object, methodName) {
      localEnvir <- new.env()
      assign('methodName', methodName, envir = localEnvir)

      function(...) {
        methodName <- get('methodName', envir = localEnvir)
        method <- object$get(methodName)
        method(...)
      }
    })(object, methodName)
  }
  object
}
