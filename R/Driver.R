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

setClass("LoggingDBIDriver", contains = "DBIDriver",
         slots = list(drv = "DBIDriver", log_call = "function"))

setMethod(
  "show", "LoggingDBIDriver",
  function(object) {
    cat("<LoggingDBIDriver>\n")
    show(object@drv)
  })

setMethod(
  "dbConnect", "LoggingDBIDriver",
  function(drv, ...) {
    drv@log_call(dbConnect(drv@drv, !!! enquos(...)))
  }
)

setMethod(
  "dbDataType", "LoggingDBIDriver",
  function(dbObj, obj, ...) {
    dbObj@log_call(dbDataType(dbObj@drv, obj, !!! enquos(...)))
  })

setMethod(
  "dbIsValid", "LoggingDBIDriver",
  function(dbObj, ...) {
    dbObj@log_call(dbIsValid(dbObj@drv, !!! enquos(...)))
  })

setMethod(
  "dbGetInfo", "LoggingDBIDriver",
  function(dbObj, ...) {
    dbObj@log_call(dbGetInfo(dbObj@drv, !!! enquos(...)))
  })
