#' @include Connection.R
NULL

setClass(
  "LoggingDBIResult",
  contains = "DBIResult",
  slots = list(res = "DBIResult", log_call = "function")
)

setMethod(
  "show", "LoggingDBIResult",
  function(object) {
    cat("<LoggingDBIResult>\n")
    show(object@res)
  })

setMethod(
  "dbClearResult", "LoggingDBIResult",
  function(res, ...) {
    res@log_call(dbClearResult(res@res, !!! enquos(...)))
  })

setMethod(
  "dbFetch", "LoggingDBIResult",
  function(res, n = -1, ...) {
    res@log_call(dbFetch(res@res, n = n, !!! enquos(...)))
  })

setMethod(
  "dbHasCompleted", "LoggingDBIResult",
  function(res, ...) {
    res@log_call(dbHasCompleted(res@res, !!! enquos(...)))
  })

setMethod(
  "dbGetInfo", "LoggingDBIResult",
  function(dbObj, ...) {
    dbObj@log_call(dbGetInfo(dbObj@res, !!! enquos(...)))
  })

setMethod(
  "dbIsValid", "LoggingDBIResult",
  function(dbObj, ...) {
    dbObj@log_call(dbIsValid(dbObj@res, !!! enquos(...)))
  })

setMethod(
  "dbGetStatement", "LoggingDBIResult",
  function(res, ...) {
    res@log_call(dbGetStatement(res@res, !!! enquos(...)))
  })

setMethod(
  "dbColumnInfo", "LoggingDBIResult",
  function(res, ...) {
    res@log_call(dbColumnInfo(res@res, !!! enquos(...)))
  })

setMethod(
  "dbGetRowCount", "LoggingDBIResult",
  function(res, ...) {
    res@log_call(dbGetRowCount(res@res, !!! enquos(...)))
  })

setMethod(
  "dbGetRowsAffected", "LoggingDBIResult",
  function(res, ...) {
    res@log_call(dbGetRowsAffected(res@res, !!! enquos(...)))
  })

setMethod(
  "dbBind", "LoggingDBIResult",
  function(res, params, ...) {
    res@log_call(dbBind(res@res, params, !!! enquos(...)))
    invisible(res)
  })
