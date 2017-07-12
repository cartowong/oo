# isNA
#
# @param x the given value
# @return TRUE if the given value is NA, and FALSE otherwise.
isNA <- function(x) {
  (length(x) == 1) && (class(x) == 'logical') && is.na(x)
}

# isNull
#
# @param x the given value
# @return TRUE if the given value is null, and FALSE otherwise.
isNull <- function(x) {
  (length(x) == 0) && (class(x) == 'NULL') && is.null(x)
}

# isBoolean
#
# @param x the given value
# @param allowNA Should NA be allowed?
# @param allowNull Should NULL be allowed?
# @return TRUE if the given value is a boolean value, and FALSE otherwise.
isBoolean <- function(x, allowNA = FALSE, allowNull = FALSE) {
  if (allowNA && isNA(x)) {
    return(TRUE)
  }

  if (allowNull && isNull(x)) {
    return(TRUE)
  }

  (length(x) == 1) && (class(x) == 'logical') && is.logical(x)
}

# isFunction
#
# @param x the given value
# @param allowNA Should NA be allowed?
# @param allowNull Should NULL be allowed?
# @return TRUE if the given value is a function, and FALSE otherwise.
isFunction <- function(x, allowNA = FALSE, allowNull = FALSE) {
  if (allowNA && isNA(x)) {
    return(TRUE)
  }

  if (allowNull && isNull(x)) {
    return(TRUE)
  }

  (length(x) == 1) && (class(x) == 'function') && is.function(x)
}

# isNumeric
#
# @param x the given value
# @param allowNA Should NA be allowed?
# @param allowNull Should NULL be allowed?
# @return TRUE if the given value is a numeric value, and FALSE otherwise.
isNumeric <- function(x, allowNA = FALSE, allowNull = FALSE) {
  if (allowNA && isNA(x)) {
    return(TRUE)
  }

  if (allowNull && isNull(x)) {
    return(TRUE)
  }

  (length(x) == 1) && (class(x) == 'numeric') && is.numeric(x)
}

# isString
#
# @param x the given value
# @param allowNA Should NA be allowed?
# @param allowNull Should NULL be allowed?
# @return TRUE if the given value is a string, and FALSE otherwise.
isString <- function(x, allowNA = FALSE, allowNull = FALSE) {
  if (allowNA && isNA(x)) {
    return(TRUE)
  }

  if (allowNull && isNull(x)) {
    return(TRUE)
  }

  (length(x) == 1) && (class(x) == 'character') && is.character(x)
}

#' Constructor of the class TypeChecker
#'
#' Utility functions for checking the type of an object. Unlike, for example, is.numeric in the base
#' package, the function isNumeric in TypeChecker checks whether the given object is a single numeric
#' value. A vector of two numeric values is not considered as numeric type. Conceptually, its type
#' is vector whose element type happens to be numeric.
#'
#' @param allowNA Should NA be allowed? The method isNull ignores this parameter.
#' @param allowNull Should NULL be allowed? The method isNA ignores this parameter.
#' @return an instance of TypeChecker
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
TypeChecker <- function(allowNA = FALSE, allowNull = FALSE) {

  if (!isBoolean(allowNA)) {
    stop('allowNA should be a boolean')
  }

  if (!isBoolean(allowNull)) {
    stop('allowNull should be a boolean')
  }

  typeChecker <- Object()

  allowNA <- allowNA
  allowNull <- allowNull

  typeChecker$addMethod('isNA', isNA)

  typeChecker$addMethod('isNull', isNull)

  typeChecker$addMethod('isBoolean', function(x) { isBoolean(x, allowNA = allowNA, allowNull = allowNull) })

  typeChecker$addMethod('isFunction', function(x) { isFunction(x, allowNA = allowNA, allowNull = allowNull) })

  typeChecker$addMethod('isNumeric', function(x) { isNumeric(x, allowNA = allowNA, allowNull = allowNull) })

  typeChecker$addMethod('isString', function(x) { isString(x, allowNA = allowNA, allowNull = allowNull) })

  typeChecker$finalize()
}
