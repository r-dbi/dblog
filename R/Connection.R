#' @include Driver.R
NULL

#' @rdname DBI
#' @export
setClass(
  "LoggingDBIConnection",
  contains = "DBIConnection",
  slots = list(conn = "DBIConnection", log_call = "function")
)

#' @rdname DBI
#' @inheritParams methods::show
#' @export
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

#' @rdname DBI
#' @inheritParams DBI::dbIsValid
#' @export
setMethod(
  "dbIsValid", "LoggingDBIConnection",
  function(dbObj, ...) {
    dbObj@log_call(dbIsValid(dbObj@conn, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbDisconnect
#' @export
setMethod(
  "dbDisconnect", "LoggingDBIConnection",
  function(conn, ...) {
    conn@log_call(dbDisconnect(conn@conn, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbSendQuery
#' @export
setMethod(
  "dbSendQuery", c("LoggingDBIConnection", "character"),
  function(conn, statement, ...) {
    conn@log_call(dbSendQuery(conn@conn, statement, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbGetQuery
#' @export
setMethod(
  "dbGetQuery", c("LoggingDBIConnection", "character"),
  function(conn, statement, ...) {
    conn@log_call(dbGetQuery(conn@conn, statement, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbSendStatement
#' @export
setMethod(
  "dbSendStatement", c("LoggingDBIConnection", "character"),
  function(conn, statement, ...) {
    conn@log_call(dbSendStatement(conn@conn, statement, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbDataType
#' @export
setMethod(
  "dbDataType", "LoggingDBIConnection",
  function(dbObj, obj, ...) {
    conn@log_call(dbDataType(dbObj@conn, obj, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbQuoteString
#' @export
setMethod(
  "dbQuoteString", c("LoggingDBIConnection", "character"),
  function(conn, x, ...) {
    conn@log_call(dbQuoteString(conn@conn, x, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbQuoteIdentifier
#' @export
setMethod(
  "dbQuoteIdentifier", c("LoggingDBIConnection", "character"),
  function(conn, x, ...) {
    conn@log_call(dbQuoteIdentifier(conn@conn, x, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbQuoteIdentifier
setMethod(
  "dbUnquoteIdentifier", c("LoggingDBIConnection", "SQL"),
  function(conn, x, ...) {
    conn@log_call(dbUnquoteIdentifier(conn@conn, x, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbWriteTable
#' @param overwrite Allow overwriting the destination table. Cannot be
#'   `TRUE` if `append` is also `TRUE`.
#' @param append Allow appending to the destination table. Cannot be
#'   `TRUE` if `overwrite` is also `TRUE`.
#' @export
setMethod(
  "dbWriteTable", c("LoggingDBIConnection", "character", "data.frame"),
  function(conn, name, value, overwrite = FALSE, append = FALSE, ...) {
    conn@log_call(dbWriteTable(conn@conn, name = name, value = value, overwrite = overwrite, append = append, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbReadTable
#' @export
setMethod(
  "dbReadTable", c("LoggingDBIConnection", "character"),
  function(conn, name, ...) {
    conn@log_call(dbReadTable(conn@conn, name = name, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbListTables
#' @export
setMethod(
  "dbListTables", "LoggingDBIConnection",
  function(conn, ...) {
    conn@log_call(dbListTables(conn@conn, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbExistsTable
#' @export
setMethod(
  "dbExistsTable", c("LoggingDBIConnection", "character"),
  function(conn, name, ...) {
    conn@log_call(dbExistsTable(conn@conn, name, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbListFields
#' @export
setMethod(
  "dbListFields", c("LoggingDBIConnection", "character"),
  function(conn, name, ...) {
    conn@log_call(dbListFields(conn@conn, name, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbRemoveTable
#' @export
setMethod(
  "dbRemoveTable", c("LoggingDBIConnection", "character"),
  function(conn, name, ...) {
    conn@log_call(dbRemoveTable(conn@conn, name, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbGetInfo
#' @export
setMethod(
  "dbGetInfo", "LoggingDBIConnection",
  function(dbObj, ...) {
    conn@log_call(dbGetInfo(dbObj@conn, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbBegin
#' @export
setMethod(
  "dbBegin", "LoggingDBIConnection",
  function(conn, ...) {
    conn@log_call(dbBegin(conn@conn, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbCommit
#' @export
setMethod(
  "dbCommit", "LoggingDBIConnection",
  function(conn, ...) {
    conn@log_call(dbCommit(conn@conn, !!! enquos(...)))
  })

#' @rdname DBI
#' @inheritParams DBI::dbRollback
#' @export
setMethod(
  "dbRollback", "LoggingDBIConnection",
  function(conn, ...) {
    conn@log_call(dbRollback(conn@conn, !!! enquos(...)))
  })
