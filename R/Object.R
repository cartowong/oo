#' Construct an object.
#'
#' This function can be used to construct an object. Any object will have a \code{get} and a \code{set} method which allows the object to have fields. The \code{addMethod} method allows one to add a method. The \code{overrideMethod} method allows one to override a method from parent class.
#'
#' @return an object.
#' @export
#' @importFrom pryr partial
Object <- function() {

  # local environment
  localEnv <- new.env()

  # object to return
  object <- list()

  # getter
  object$get <- function(key) {
    get(key, envir = localEnv)
  }

  # setter
  object$set <- function(key, value) {
    assign(key, value, envir = localEnv)
  }

  # list all properties of this object
  object$ls <- pryr::partial(ls, envir = localEnv)

  # add a method
  object$addMethod <- function(name, f) {
    if (name %in% ls(envir = localEnv)) {
      stop(sprintf('The method %s already exists. Use overrideMethod.', name))
    }
    object$set(name, f)
  }

  # override a method
  object$overrideMethod <- function(name, f) {
    if (!(name %in% ls(envir = localEnv))) {
      stop(sprintf('Overriding a non-existing method %s', name))
    }
    parentMethod <- object$get(name)
    g <- pryr::partial(f, parentMethod = parentMethod)
    object$set(name, g)
  }

  return(object)
}
