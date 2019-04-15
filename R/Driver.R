#' DBI methods
#'
#' Implementations of pure virtual functions defined in the `DBI` package.
#' @name DBI
NULL

#' LoggingDBI driver
#'
#' TBD.
#'
#' @export
#' @param drv Driver to be wrapped.
#' @param logger Logger object, defaults to [get_default_logger()].
#' @import methods DBI
#' @examples
#' \dontrun{
#' #' library(DBI)
#' RLoggingDBI::LoggingDBI()
#' }
LoggingDBI <- function(drv, logger = get_default_logger()) {
  quo <- enquo(drv)
  logger$log_call(!! quo)
}

setClass("LoggingDBIDriver")

make_driver_class <- function(base_class) {

  template_name <- "LoggingDBIDriver"
  class_name <- paste0(template_name, "-", base_class)
  all_base_classes <- c(template_name, base_class)

  if (isClass(class_name)) {
    return(class_name)
  }

  where <- parent.frame()

  setClass <- function(...) {
    methods::setClass(..., where = where, package = .packageName)
  }

  setMethod <- function(...) {
    methods::setMethod(..., where = where)
  }

  class <- setClass(class_name,
    contains = all_base_classes, slots = list(drv = base_class, log_call = "function"))

  setMethod(
    "show", class_name,
    function(object) {
      cat("<LoggingDBIDriver>\n")
      show(object@drv)
    })

  setMethod(
    "dbConnect", class_name,
    function(drv, ...) {
      drv@log_call(dbConnect(drv@drv, !!! enquos(...)))
    }
  )

  setMethod(
    "dbDataType", class_name,
    function(dbObj, obj, ...) {
      dbObj@log_call(dbDataType(dbObj@drv, obj, !!! enquos(...)))
    })

  setMethod(
    "dbIsValid", class_name,
    function(dbObj, ...) {
      dbObj@log_call(dbIsValid(dbObj@drv, !!! enquos(...)))
    })

  setMethod(
    "dbGetInfo", class_name,
    function(dbObj, ...) {
      dbObj@log_call(dbGetInfo(dbObj@drv, !!! enquos(...)))
    })

  class_name
}
