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

#' @rdname DBI
#' @export
setClass("LoggingDBIDriver", contains = "DBIDriver",
         slots = list(drv = "DBIDriver", log_call = "function"))

#' @rdname DBI
#' @inheritParams methods::show
#' @export
setMethod(
  "show", "LoggingDBIDriver",
  function(object) {
    cat("<LoggingDBIDriver>\n")
    show(object@drv)
  })

#' @rdname DBI
#' @inheritParams DBI::dbConnect
#' @export
setMethod(
  "dbConnect", "LoggingDBIDriver",
  function(drv, ...) {
    drv@log_call(dbConnect(drv@drv, !!! enquos(...)))
  }
)

#' @rdname DBI
#' @inheritParams DBI::dbDataType
#' @export
setMethod(
  "dbDataType", "LoggingDBIDriver",
  function(dbObj, obj, ...) {
    dbObj@log_call(dbDataType(dbObj@drv, obj, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbIsValid
#' @export
setMethod(
  "dbIsValid", "LoggingDBIDriver",
  function(dbObj, ...) {
    dbObj@log_call(dbIsValid(dbObj@drv, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbGetInfo
#' @export
setMethod(
  "dbGetInfo", "LoggingDBIDriver",
  function(dbObj, ...) {
    dbObj@log_call(dbGetInfo(dbObj@drv, !!! enquos(...)))
  })
