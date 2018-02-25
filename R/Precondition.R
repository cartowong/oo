# checkIsBoolean
#
# Throw an error if the given value is not a boolean.
#
# @param x the given value
# @param message the error message
# @param allowNA Should NA be allowed?
# @param allowNull Should NULL be allowed?
checkIsBoolean <- function(x, message = 'x should be a boolean', allowNA = FALSE, allowNull = FALSE) {
  if (!isBoolean(x)) {
    stop(message)
  }
}

# checkIsFunction
#
# Throw an error if the given value is not a function.
#
# @param x the given value
# @param message the error message
# @param allowNA Should NA be allowed?
# @param allowNull Should NULL be allowed?
checkIsFunction <- function(x, message = 'x should be a function', allowNA = FALSE, allowNull = FALSE) {
  if (!isFunction(x)) {
    stop(message)
  }
}

# checkIsNumeric
#
# Throw an error if the given value is not numeric.
#
# @param x the given value
# @param message the error message
# @param allowNA Should NA be allowed?
# @param allowNull Should NULL be allowed?
checkIsNumeric <- function(x, message = 'x should be a numeric value', allowNA = FALSE, allowNull = FALSE) {
  if (!isNumeric(x)) {
    stop(message)
  }
}

# checkIsString
#
# Throw an error if the given value is not a string.
#
# @param x the given value
# @param message the error message
# @param allowNA Should NA be allowed?
# @param allowNull Should NULL be allowed?
checkIsString <- function(x, message = 'x should be a string', allowNA = FALSE, allowNull = FALSE) {
  if (!isString(x)) {
    stop(message)
  }
}

# checkNotNullNotNA
#
# Ensure the given argument is not null and is not NA.
#
# @param x the given value
# @param message the error message
checkNotNullNotNA <- function(x, message = 'x should be non-null and non-NA') {
  if (isNull(x) || isNA(x)) {
    stop(message)
  }
}

# checkArgument
#
# Ensure the truth of an expression invovling one or more parameters to the calling method.
#
# @param expression the boolean expression to check
# @param message the error message
checkArgument <- function(expression, message = "checkArgument failed") {
  if (!isBoolean(expression) || !expression) {
    stop(message)
  }
}

# checkState
#
# Ensure the truth of an expression invovling the state of the calling instance, but not
# involving any parameters to the calling method.
#
# @param expression the boolean expression to check
# @param message the error message
checkState <- function(expression, message = "checkState failed") {
  if (!isBoolean(expression) || !expression) {
    stop(message)
  }
}

#' Constructor of the class Precondition
#'
#' Utility functions for checking the type of an argument, based on TypeChecker in the same package.
#' If the argument is not of the expected type, an error will be thrown. Usually, these utility
#' functions are called at the begining of a function body.
#'
#' @param allowNA Should NA be allowed? The method checkIsNull ignores this parameter.
#' @param allowNull Should NULL be allowed? The method checkIsNA ignores this parameter.
#' @return an instance of Precondition
#'
#' @examples
#' precondition <- Precondition()
#' myFunction <- function(x) {
#'   precondition$isNumeric(x, 'x should be numeric')
#'   ...
#' }
#'
#' @export
Precondition <- function(allowNA = FALSE, allowNull = FALSE) {

  checkIsBoolean(allowNA, message = 'allowNA should be a boolean')
  checkIsBoolean(allowNull, message = 'allowNull should be a boolean')

  precondition <- Object()

  allowNA <- allowNA
  allowNull <- allowNull

  precondition$addMethod('checkIsBoolean', function(x, message) {
    checkIsBoolean(x, message, allowNA = allowNA, allowNull = allowNull)
  })

  precondition$addMethod('checkIsFunction', function(x, message) {
    checkIsFunction(x, message, allowNA = allowNA, allowNull = allowNull)
  })

  precondition$addMethod('checkIsNumeric', function(x, message) {
    checkIsNumeric(x, message, allowNA = allowNA, allowNull = allowNull)
  })

  precondition$addMethod('checkIsString', function(x, message) {
    checkIsString(x, message, allowNA = allowNA, allowNull = allowNull)
  })

  precondition$addMethod('checkNotNullNotNA', function(x, message) {
    checkNotNullNotNA(x, message)
  })

  precondition$addMethod('checkArgument', function(expression, message) {
    checkArgument(expression, message)
  })

  precondition$addMethod('checkState', function(expression, message) {
    checkState(expression, message)
  })

  precondition$finalize()
}
