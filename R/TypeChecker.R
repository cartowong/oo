#' TypeChecker
#'
#' Utility functions for checking the type of an object. Unlike, for example, is.numeric in the base
#' package, the function isNumeric in TypeChecker checks whether the given object is a single numeric
#' value. A vector of two numeric values is not considered as numeric type. Conceptually, its type
#' is vector whose element type happens to be numeric.
#'
#' @examples
#' TypeChecker$isNA(x)
#' TypeChecker$isNull(x)
#' TypeChecker$isBoolean(x)
#' TypeChecker$isFunction(x)
#' TypeChecker$isNumeric(x)
#' TypeChecker$isString(x)
#'
#' @export
TypeChecker <- list(
  isNA = function(x) { ifelse((length(x) == 1) && (class(x) == 'logical'), is.na(x), FALSE) },

  isNull = function(x) { ifelse((length(x) == 0) && (class(x) == 'NULL'), is.null(x), FALSE) },

  isBoolean = function(x) { ifelse((length(x) == 1) && (class(x) == 'logical'), is.logical(x), FALSE) },

  isFunction = function(x) { ifelse((length(x) == 1) && (class(x) == 'function'), is.function(x), FALSE) },

  isNumeric = function(x) { ifelse((length(x) == 1) && (class(x) == 'numeric'), is.numeric(x), FALSE) },

  isString = function(x) { ifelse((length(x) == 1) && (class(x) == 'character'), is.character(x), FALSE) }
)
