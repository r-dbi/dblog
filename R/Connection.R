#' @include Driver.R
NULL

setClass(
  "LoggingDBIConnection",
  contains = "DBIConnection",
  slots = list(conn = "DBIConnection", log_call = "function")
)

setMethod(
  "show", "LoggingDBIConnection",
  function(object) {
    cat("<LoggingDBIConnection>\n")
    show(object@conn)
  })

#' @export
format.LoggingDBIConnection <- function(x, ...) {
  paste0("Logging<", format(x@conn), ">")
}

setMethod(
  "dbIsValid", "LoggingDBIConnection",
  function(dbObj, ...) {
    dbObj@log_call(dbIsValid(dbObj@conn, !!! enquos(...)))
  })

setMethod(
  "dbDisconnect", "LoggingDBIConnection",
  function(conn, ...) {
    conn@log_call(dbDisconnect(conn@conn, !!! enquos(...)))
  })

setMethod(
  "dbSendQuery", c("LoggingDBIConnection", "character"),
  function(conn, statement, ...) {
    conn@log_call(dbSendQuery(conn@conn, statement, !!! enquos(...)))
  })

setMethod(
  "dbGetQuery", c("LoggingDBIConnection", "character"),
  function(conn, statement, ...) {
    conn@log_call(dbGetQuery(conn@conn, statement, !!! enquos(...)))
  })

setMethod(
  "dbSendStatement", c("LoggingDBIConnection", "character"),
  function(conn, statement, ...) {
    conn@log_call(dbSendStatement(conn@conn, statement, !!! enquos(...)))
  })

setMethod(
  "dbDataType", "LoggingDBIConnection",
  function(dbObj, obj, ...) {
    dbObj@log_call(dbDataType(dbObj@conn, obj, !!! enquos(...)))
  })

setMethod(
  "dbQuoteString", c("LoggingDBIConnection", "character"),
  function(conn, x, ...) {
    conn@log_call(dbQuoteString(conn@conn, x, !!! enquos(...)))
  })

setMethod(
  "dbQuoteIdentifier", c("LoggingDBIConnection", "character"),
  function(conn, x, ...) {
    conn@log_call(dbQuoteIdentifier(conn@conn, x, !!! enquos(...)))
  })

setMethod(
  "dbUnquoteIdentifier", c("LoggingDBIConnection", "SQL"),
  function(conn, x, ...) {
    conn@log_call(dbUnquoteIdentifier(conn@conn, x, !!! enquos(...)))
  })

#' @param overwrite Allow overwriting the destination table. Cannot be
#'   `TRUE` if `append` is also `TRUE`.
#' @param append Allow appending to the destination table. Cannot be
#'   `TRUE` if `overwrite` is also `TRUE`.
setMethod(
  "dbWriteTable", c("LoggingDBIConnection", "character", "data.frame"),
  function(conn, name, value, overwrite = FALSE, append = FALSE, ...) {
    conn@log_call(dbWriteTable(conn@conn, name = name, value = value, overwrite = overwrite, append = append, !!! enquos(...)))
  })

setMethod(
  "dbReadTable", c("LoggingDBIConnection", "character"),
  function(conn, name, ...) {
    conn@log_call(dbReadTable(conn@conn, name = name, !!! enquos(...)))
  })

setMethod(
  "dbListTables", "LoggingDBIConnection",
  function(conn, ...) {
    conn@log_call(dbListTables(conn@conn, !!! enquos(...)))
  })

setMethod(
  "dbExistsTable", c("LoggingDBIConnection", "character"),
  function(conn, name, ...) {
    conn@log_call(dbExistsTable(conn@conn, name, !!! enquos(...)))
  })

setMethod(
  "dbListFields", c("LoggingDBIConnection", "character"),
  function(conn, name, ...) {
    conn@log_call(dbListFields(conn@conn, name, !!! enquos(...)))
  })

setMethod(
  "dbRemoveTable", c("LoggingDBIConnection", "character"),
  function(conn, name, ...) {
    conn@log_call(dbRemoveTable(conn@conn, name, !!! enquos(...)))
  })

setMethod(
  "dbGetInfo", "LoggingDBIConnection",
  function(dbObj, ...) {
    dbObj@log_call(dbGetInfo(dbObj@conn, !!! enquos(...)))
  })

setMethod(
  "dbBegin", "LoggingDBIConnection",
  function(conn, ...) {
    conn@log_call(dbBegin(conn@conn, !!! enquos(...)))
  })

setMethod(
  "dbCommit", "LoggingDBIConnection",
  function(conn, ...) {
    conn@log_call(dbCommit(conn@conn, !!! enquos(...)))
  })

setMethod(
  "dbRollback", "LoggingDBIConnection",
  function(conn, ...) {
    conn@log_call(dbRollback(conn@conn, !!! enquos(...)))
  })
