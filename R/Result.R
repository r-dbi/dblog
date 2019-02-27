#' @include Connection.R
NULL

LoggingDBIResult <- function(res) {
  new("LoggingDBIResult", res = res)
}

#' @rdname DBI
#' @export
setClass(
  "LoggingDBIResult",
  contains = "DBIResult",
  slots = list(res = "DBIResult")
)

#' @rdname DBI
#' @inheritParams methods::show
#' @export
setMethod(
  "show", "LoggingDBIResult",
  function(object) {
    cat("<LoggingDBIResult>\n")
    show(object@res)
  })

#' @rdname DBI
#' @inheritParams DBI::dbClearResult
#' @export
setMethod(
  "dbClearResult", "LoggingDBIResult",
  function(res, ...) {
    log_call(dbClearResult(res@res, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbFetch
#' @export
setMethod(
  "dbFetch", "LoggingDBIResult",
  function(res, n = -1, ...) {
    log_call(dbFetch(res@res, n = n, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbHasCompleted
#' @export
setMethod(
  "dbHasCompleted", "LoggingDBIResult",
  function(res, ...) {
    log_call(dbHasCompleted(res@res, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbGetInfo
#' @export
setMethod(
  "dbGetInfo", "LoggingDBIResult",
  function(dbObj, ...) {
    log_call(dbGetInfo(dbObj@res, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbIsValid
#' @export
setMethod(
  "dbIsValid", "LoggingDBIResult",
  function(dbObj, ...) {
    log_call(dbIsValid(dbObj@res, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbGetStatement
#' @export
setMethod(
  "dbGetStatement", "LoggingDBIResult",
  function(res, ...) {
    log_call(dbGetStatement(res@res, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbColumnInfo
#' @export
setMethod(
  "dbColumnInfo", "LoggingDBIResult",
  function(res, ...) {
    log_call(dbColumnInfo(res@res, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbGetRowCount
#' @export
setMethod(
  "dbGetRowCount", "LoggingDBIResult",
  function(res, ...) {
    log_call(dbGetRowCount(res@res, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbGetRowsAffected
#' @export
setMethod(
  "dbGetRowsAffected", "LoggingDBIResult",
  function(res, ...) {
    log_call(dbGetRowsAffected(res@res, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbBind
#' @export
setMethod(
  "dbBind", "LoggingDBIResult",
  function(res, params, ...) {
    log_call(dbBind(res@res, params, !!! enquos(...)))
    invisible(res)
  })
