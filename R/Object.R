#' Construct an object.
#'
#' This function should be called at the begining of a constructor function to create an object.
#'
#' @return an object.
#' @details Any object has the methods "get", "set", "setPrivate", "addMethod", "addPrivateMethod", "extend", "overrideMethod", and "finalize". For more details, see http://www.github.com/cartowong/oo.
#' @export
Object <- function() {
  createObject(
    publicFieldEnv = new.env(),
    privateFieldEnv = new.env(),
    publicMethodEnv = new.env(),
    privateMethodEnv = new.env()
  )
}

# Package private helper function of Object.
#
# @return an object
createObject <- function(publicFieldEnv, privateFieldEnv, publicMethodEnv, privateMethodEnv) {

  # public environment
  publicFieldEnv <- publicFieldEnv

  # private environment
  privateFieldEnv <- privateFieldEnv

  # public method environment
  publicMethodEnv <- publicMethodEnv

  # private method environment
  privateMethodEnv <- privateMethodEnv

  # Get the value of a field
  #
  # @param key the name of the field
  # @param includePrivate If TRUE, both public or private field may be returned.
  # @return the value of the field
  getField <- function(key, includePrivate) {
    checkIsString(key, 'key should be a string')
    checkIsBoolean(includePrivate, 'includePrivate should be a boolean')

    if (key %in% ls(envir = publicFieldEnv)) {
      return(get(key, envir = publicFieldEnv))
    }
    if (includePrivate && (key %in% ls(envir = privateFieldEnv))) {
      return(get(key, envir = privateFieldEnv))
    }
    stop(sprintf('The field %s does not exist in the current object!', key))
  }

  # Get a method
  #
  # @param methodName the name of the method
  # @param includePrivate If TRUE, both public or private method may be returned.
  # @return the method
  getMethod <- function(methodName, includePrivate) {
    checkIsString(methodName, 'methodName should be a string')
    checkIsBoolean(includePrivate, 'includePrivate should be a boolean')

    if (methodName %in% ls(envir = publicMethodEnv)) {
      return(get(methodName, envir = publicMethodEnv))
    }
    if (includePrivate && (methodName %in% ls(envir = privateMethodEnv))) {
      return(get(methodName, envir = privateMethodEnv))
    }
    stop(sprintf('The method %s does not exist in the current object!', methodName))
  }

  # Does the given function have an argument of the given name?
  #
  # @param f       the given function
  # @param argName the given argument name
  # @return TRUE if the given function has an argument of the given name, and FALSE otherwise
  hasArg <- function(f, argName) {
    checkIsFunction(f, 'f should be a function')
    checkIsString(argName, 'argName should be a string')

    argName %in% names(formals(f))
  }

  # Add a method to this object.
  #
  # @param methodName the name of the method
  # @param f the function to be executed when the method is called
  # @return void
  addMethod <- function(methodName, f, envir) {
    checkIsString(methodName, 'methodName should be a string')
    checkIsFunction(f, 'f should be a function')

    publicMethodNames <- ls(envir = publicMethodEnv)
    privateMethodNames <- ls(envir = privateMethodEnv)
    if ((methodName %in% publicMethodNames) || (methodName %in% privateMethodNames)) {
      stop(sprintf('The method %s already exists. Use another method name or use overrideMethod.', methodName))
    }
    g <- function(...) {
      if (hasArg(f, 'this')) {
        object <- registerMethods(object, privateMethodNames)
        object <- registerMethods(object, publicMethodNames)
        f(this = object, ...)
      } else {
        f(...)
      }
    }
    assign(methodName, g, envir = envir)
  }

  # Override a method
  #
  # @param methodName the method name
  # @param f the function to be executed when the method is called
  # @return void
  overrideMethod <- function(methodName, f) {
    checkIsString(methodName, 'methodName should be a string')
    checkIsFunction(f, 'f should be a function')

    publicMethodNames <- ls(envir = publicMethodEnv)
    privateMethodNames <- ls(envir = privateMethodEnv)
    if (!(methodName %in% publicMethodNames)) {
      stop(sprintf('Overriding a non-existing or private method %s', methodName))
    }

    parentMethod <- get(methodName, envir = publicMethodEnv)
    g <- function(...) {
      if (hasArg(f, 'this')) {
        object <- registerMethods(object, privateMethodNames)
        object <- registerMethods(object, publicMethodNames)

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
    assign(methodName, g, envir = publicMethodEnv)
  }

  # Extend an object.
  #
  # @return the extended object with its own private environments
  extend <- function() {
    object <- createObject(
      publicFieldEnv = publicFieldEnv,
      privateFieldEnv = new.env(),
      publicMethodEnv = publicMethodEnv,
      privateMethodEnv = new.env()
    )
    object$overrideMethod <- overrideMethod
    object
  }

  # Register methods so that they can be referenced as properties of the object.
  #
  # @return the object with methods registered
  registerMethods <- function(object, methodNames) {
    for (methodName in methodNames) {
      if (!(methodName %in% ls(envir = publicMethodEnv)) && !(methodName %in% ls(envir = privateMethodEnv))) {
        stop(sprintf('Registering a non-existing method %s!', methodName))
      }

      # use immediate function to create a unique environment for each method
      object[[methodName]] <- (function(object, methodName) {

        # make sure the function below can resolve these symbols at runtime
        object <- object
        methodName <- methodName

        # Since the method may be overriden after it is registered, we obtain the method from the
        # object's local environment.
        function(...) {
          method <- getMethod(methodName, includePrivate = TRUE)
          method(...)
        }
      })(object, methodName)
    }
    object
  }

  # Finalize an object
  #
  # @return the finalized object
  finalize <- function() {
    # register all public methods
    object <- registerMethods(object, object$methodNames())

    # remove private setter
    object$setPrivate <- NULL
    object$addPrivateMethod <- NULL

    # remove private getter
    object$get <- function(key) {
      getField(key, includePrivate = FALSE)
    }

    # remove other non-public methods
    object$addMethod <- NULL
    object$finalize <- NULL

    object
  }

  # ========== Construct the object ==========

  # object to return
  object <- list()

  # getter
  object$get <- function(key) {
    getField(key, includePrivate = TRUE)
  }

  # setter
  object$set <- function(key, value) {
    checkIsString(key, 'key should be a string')

    # Throw an error if the field already exists as a private field.
    if (key %in% ls(envir = privateFieldEnv)) {
      stop(sprintf('The private field %s already exists. Make it public or call setPrivate(key, value).', key))
    }

    assign(key, value, envir = publicFieldEnv)
    key
  }

  # setter
  object$setPrivate <- function(key, value) {
    checkIsString(key, 'key should be a string')

    # Throw an error if the field already exists as a public field.
    if (key %in% ls(envir = publicFieldEnv)) {
      stop(sprintf('The public field %s already exists. Make it private or call set(key, value).', key))
    }

    assign(key, value, envir = privateFieldEnv)
    key
  }

  # list all public fields
  object$fieldNames <- function() {
    ls(envir = publicFieldEnv)
  }

  # list all public methods
  object$methodNames <- function() {
    ls(envir = publicMethodEnv)
  }

  # add a public method
  object$addMethod <- function(methodName, f) {
    addMethod(methodName, f, envir = publicMethodEnv)
  }

  # add a private method
  object$addPrivateMethod <- function(methodName, f) {
    addMethod(methodName, f, envir = privateMethodEnv)
  }

  # extend an object
  object$extend <- extend

  # finalize an object
  object$finalize <- finalize

  return(object)
}
