#' Source all R script files under the given path, recursively.
#'
#' @param path a string. The path of a directory in which all R script files will be sourced.
#' @param ignore a regular expression string. Any matching file path will not be sourced.
#' @return a vector of strings. The paths of the sourced files.
#' @export
include <- function(path, ignore = NA) {
  checkIsString(path, 'path should be a string')
  if (!isNA(ignore)) {
    checkIsString(ignore, 'ignore should be a string')
  }
  if (!dir.exists(path)) {
    stop(sprintf('Not an existing directory: %s', path))
  }

  # remove / or \ at the end of the path
  fileSep <- .Platform$file.sep # / or \ depending on the platform
  pattern <- sprintf('(.*)%s$', fileSep)
  path <- gsub(pattern = pattern, replacement = '\\1', x = path)

  files <- list.files(path = path, include.dirs = FALSE, recursive = TRUE)
  scriptFiles <- c()
  for (file in files) {
    if (grepl(pattern = '\\.R$', x = file)) {
      filePath <- file.path(path, file)
      shouldIgnore <- !isNA(ignore) && grepl(pattern = ignore, x = filePath)
      if (!shouldIgnore) {
        scriptFiles <- append(scriptFiles, filePath)
        source(filePath)
      }
    }
  }

  scriptFiles
}
