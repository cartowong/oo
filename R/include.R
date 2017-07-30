#' Source all R script files under the given path, recursively.
#'
#' @param path a string. The path of a directory in which all R script files will be sourced.
#' @return a vector of strings. The paths of the sourced files.
#' @export
include <- function(path) {
  checkIsString(path, 'path should be a string')
  if (!dir.exists(path)) {
    stop(sprintf('Not an existing directory: %s', path))
  }

  files <- list.files(path = path, include.dirs = FALSE, recursive = TRUE)
  scriptFiles <- c()
  for (file in files) {
    if (grepl(pattern = '\\.R$', x = file)) {
      filePath <- file.path(path, file)
      scriptFiles <- append(scriptFiles, filePath)
      source(filePath)
    }
  }

  scriptFiles
}
