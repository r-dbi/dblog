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
#' @import methods DBI
#' @examples
#' \dontrun{
#' #' library(DBI)
#' RLoggingDBI::LoggingDBI()
#' }
LoggingDBI <- function(drv) {
  quo <- enquo(drv)
  log_drv <- log_call(!! quo)
  new("LoggingDBIDriver", drv = log_drv)
}

#' @rdname DBI
#' @export
setClass("LoggingDBIDriver", contains = "DBIDriver", slots = list(drv = "DBIDriver"))

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
    conn <- log_call(dbConnect(drv@drv, !!! enquos(...)))
    LoggingDBIConnection(conn)
  }
)

#' @rdname DBI
#' @inheritParams DBI::dbDataType
#' @export
setMethod(
  "dbDataType", "LoggingDBIDriver",
  function(dbObj, obj, ...) {
    log_call(dbDataType(dbObj@drv, obj, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbIsValid
#' @export
setMethod(
  "dbIsValid", "LoggingDBIDriver",
  function(dbObj, ...) {
    log_call(dbIsValid(dbObj@drv, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbGetInfo
#' @export
setMethod(
  "dbGetInfo", "LoggingDBIDriver",
  function(dbObj, ...) {
    log_call(dbGetInfo(dbObj@drv, !!! enquos(...)))
  })
