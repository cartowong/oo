#' Construct an object.
#'
#' This function should be called at the begining of a constructor function to create an object.
#'
#' @return an object.
#' @details Any object has the methods "define", "definePrivate", "get", "set", "fieldNames", "methodNames", "addMethod", "addPrivateMethod", "extend", and "finalize". Some of these methods are removed after finalize() is called. For more details, see http://www.github.com/cartowong/oo.
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

  # Check if a variable exists in a given environment
  #
  # @param key the name of the variable
  # @param envir the environment in which we search for the variable
  # @return TRUE if the variable exists in the environment, and FALSE otherwise.
  existsIn <- function(key, envir) {
    checkIsString(key, 'key should be a string')
    key %in% ls(envir = envir)
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

  # Define a field.
  #
  # @param key the name of the field
  # @param value the value of the field
  # @param isPublic Is it a public field?
  # @return the key
  defineField <- function(key, value, isPublic) {
    checkIsString(key, 'key should be a string')
    checkIsBoolean(isPublic, 'isPublic should be a boolean')
    if (existsIn(key, publicFieldEnv) || existsIn(key, privateFieldEnv)) {
      stop(sprintf('The field %s already exists!', key))
    }
    if (isPublic) {
      assign(key, value, envir = publicFieldEnv)
    } else {
      assign(key, value, envir = privateFieldEnv)
    }
    key
  }

  # Get the value of a field
  #
  # @param key the name of the field
  # @param includePrivate If TRUE, both public or private field may be returned.
  # @return the value of the field
  getField <- function(key, includePrivate) {
    checkIsString(key, 'key should be a string')
    checkIsBoolean(includePrivate, 'includePrivate should be a boolean')

    if (existsIn(key, publicFieldEnv)) {
      return(get(key, envir = publicFieldEnv))
    } else if (includePrivate && existsIn(key, privateFieldEnv)) {
      return(get(key, envir = privateFieldEnv))
    }
    stop(sprintf('The field %s does not exist in the current object or it is private!', key))
  }

  # Set the value of a field
  #
  # @param key the name of the field
  # @param includePrivate If TRUE, both public or private field may be set.
  # @return the value of the field
  setField <- function(key, value, includePrivate) {
    checkIsString(key, 'key should be a string')
    checkIsBoolean(includePrivate, 'includePrivate should be a boolean')

    if (existsIn(key, publicFieldEnv)) {
      assign(key, value, envir = publicFieldEnv)
      return(value)
    } else if (includePrivate && existsIn(key, privateFieldEnv)) {
      assign(key, value, envir = privateFieldEnv)
      return(value)
    }
    stop(sprintf('The field %s does not exist in the current object or it is private!', key))
  }

  # Get a method
  #
  # @param methodName the name of the method
  # @param includePrivate If TRUE, both public or private method may be returned.
  # @return the method
  getMethod <- function(methodName, includePrivate) {
    checkIsString(methodName, 'methodName should be a string')
    checkIsBoolean(includePrivate, 'includePrivate should be a boolean')

    if (existsIn(methodName, publicMethodEnv)) {
      return(get(methodName, envir = publicMethodEnv))
    }
    if (includePrivate && existsIn(methodName, privateMethodEnv)) {
      return(get(methodName, envir = privateMethodEnv))
    }
    stop(sprintf('The method %s does not exist in the current object or it is private!', methodName))
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
      if (!existsIn(methodName, publicMethodEnv) && !existsIn(methodName, privateMethodEnv)) {
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
    object$set <- function(key, value) {
      setField(key, value, includePrivate = FALSE)
    }
    object$addPrivateMethod <- NULL

    # remove private getter
    object$get <- function(key) {
      getField(key, includePrivate = FALSE)
    }

    # remove other non-public methods
    object$define <- NULL
    object$definePrivate <- NULL
    object$addMethod <- NULL
    object$finalize <- NULL

    object
  }

  # ========== Construct the object ==========

  # object to return
  object <- list()

  # define a public field
  object$define <- function(key, value = NA) {
    defineField(key, value, isPublic = TRUE)
  }

  # define a private field
  object$definePrivate <- function(key, value = NA) {
    defineField(key, value, isPublic = FALSE)
  }

  # getter
  object$get <- function(key) {
    getField(key, includePrivate = TRUE)
  }

  # setter
  object$set <- function(key, value) {
    setField(key, value, includePrivate = TRUE)
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
