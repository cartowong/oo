#' Construct an object.
#'
#' This function should be called at the begining of a constructor function to create an object.
#'
#' @return an object.
#' @details Any object has the methods "get", "getPrivate". "set", "setPrivate", "ls", "addMethod", and "overrideMethod". For more details, see http://www.github.com/cartowong/oo.
#' @export
Object <- function() {

  # public environment
  publicEnv <- new.env()

  # private environment
  privateEnv <- new.env()

  # Does the given function have an argument of the given name?
  #
  # @param f       the given function
  # @param argName the given argument name
  #
  # @return TRUE if the given function has an argument of the given name, and FALSE otherwise
  hasArg <- function(f, argName) {
    argList <- formals(f)
    pattern <- sprintf('%s.*=', argName)
    grepl(pattern = pattern, deparse(argList))
  }

  # object to return
  object <- list()

  # getter
  object$get <- function(key) {
    get(key, envir = publicEnv)
  }

  # getter
  object$getPrivate <- function(key) {
    get(key, envir = privateEnv)
  }

  # setter
  object$set <- function(key, value) {
    assign(key, value, envir = publicEnv)
  }

  # setter
  object$setPrivate <- function(key, value) {
    assign(key, value, envir = privateEnv)
  }

  # list all properties of this object
  object$ls <- function(...) {
    ls(envir = publicEnv, ...)
  }

  # add a method
  object$addMethod <- function(name, f) {
    if (name %in% ls(envir = publicEnv)) {
      stop(sprintf('The method %s already exists. Use overrideMethod.', name))
    }
    g <- function(...) {
      if (hasArg(f, 'this')) {
        f(this = object, ...)
      } else {
        f(...)
      }
    }
    object$set(name, g)
  }

  # override a method
  object$overrideMethod <- function(name, f) {
    if (!(name %in% ls(envir = publicEnv))) {
      stop(sprintf('Overriding a non-existing method %s', name))
    }
    parentMethod <- object$get(name)
    g <- function(...) {
      if (hasArg(f, 'this')) {
        if (hasArg(f, 'parentMethod')) {
          f(this = object, parentMethod = parentMethod, ...)
        }
        else {
          f(this = object, ...)
        }
      } else { # Otherwise, f does not have an argument 'this'.
        if (hasArg(f, 'parentMethod')) {
          f(parentMethod = parentMethod, ...)
        }
        else {
          f(...)
        }
      }
    }
    object$set(name, g)
  }

  return(object)
}
