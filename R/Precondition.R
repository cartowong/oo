#' Precondition
#'
#' Utility functions for checking the type of an argument, based on TypeChecker in the same package.
#' If the argument is not of the expected type, an error will be thrown. Usually, these utility
#' functions are called at the begining of a function body.
#'
#' @examples
#' myFunction <- function(x) {
#'   Precondition$isNumeric(x, 'x is not numeric')
#'   ...
#' }
#'
#' @export
Precondition <- list(
  checkIsNA = function(x, message = 'x should be NA') {
    if (!TypeChecker$isNA(x)) {
      stop(message)
    }
  },

  checkIsNull = function(x, message = 'x should be null') {
    if (!TypeChecker$isNull(x)) {
      stop(message)
    }
  },

  checkIsBoolean = function(x, message = 'x should a boolean') {
    if (!TypeChecker$isBoolean(x)) {
      stop(message)
    }
  },

  checkIsString = function(x, message = 'x should be a string') {
    if (!TypeChecker$isString(x)) {
      stop(message)
    }
  },

  checkIsNumeric = function(x, message = 'x should be a numeric value') {
    if (!TypeChecker$isNumeric(x)) {
      stop(message)
    }
  },

  checkIsFunction = function(x, message = 'x should be a function') {
    if (!TypeChecker$isFunction(x)) {
      stop(message)
    }
  }
)
