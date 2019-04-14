#' @include Driver.R
NULL

setClass("LoggingDBIConnection")

#' @export
format.LoggingDBIConnection <- function(x, ...) {
  paste0("Logging<", format(x@conn), ">")
}

make_connection_class <- function(base_class) {

  template_name <- "LoggingDBIConnection"
  class_name <- paste0(template_name, "-", base_class)
  all_base_classes <- c(template_name, base_class)

  if (isClass(class_name)) {
    return(class_name)
  }

  class <- setClass(class_name,
    contains = all_base_classes, slots = list(conn = base_class, log_call = "function"))

  setMethod(
    "show", class_name,
    function(object) {
      cat("<LoggingDBIConnection>\n")
      show(object@conn)
    })

  setMethod(
    "dbIsValid", class_name,
    function(dbObj, ...) {
      dbObj@log_call(dbIsValid(dbObj@conn, !!! enquos(...)))
    })

  setMethod(
    "dbDisconnect", class_name,
    function(conn, ...) {
      conn@log_call(dbDisconnect(conn@conn, !!! enquos(...)))
    })

  setMethod(
    "dbSendQuery", c(class_name, "character"),
    function(conn, statement, ...) {
      conn@log_call(dbSendQuery(conn@conn, statement, !!! enquos(...)))
    })

  setMethod(
    "dbGetQuery", c(class_name, "character"),
    function(conn, statement, ...) {
      conn@log_call(dbGetQuery(conn@conn, statement, !!! enquos(...)))
    })

  setMethod(
    "dbSendStatement", c(class_name, "character"),
    function(conn, statement, ...) {
      conn@log_call(dbSendStatement(conn@conn, statement, !!! enquos(...)))
    })

  setMethod(
    "dbDataType", class_name,
    function(dbObj, obj, ...) {
      dbObj@log_call(dbDataType(dbObj@conn, obj, !!! enquos(...)))
    })

  setMethod(
    "dbQuoteString", c(class_name, "character"),
    function(conn, x, ...) {
      conn@log_call(dbQuoteString(conn@conn, x, !!! enquos(...)))
    })

  setMethod(
    "dbQuoteIdentifier", class_name,
    function(conn, x, ...) {
      barf
      conn@log_call(dbQuoteIdentifier(conn@conn, x, !!! enquos(...)))
    })

  setMethod(
    "dbQuoteIdentifier", c(class_name, "character"),
    function(conn, x, ...) {
      barf
      conn@log_call(dbQuoteIdentifier(conn@conn, x, !!! enquos(...)))
    })

  setMethod(
    "dbQuoteIdentifier", c(class_name, "SQL"),
    function(conn, x, ...) {
      barf
      conn@log_call(dbQuoteIdentifier(conn@conn, x, !!! enquos(...)))
    })

  setMethod(
    "dbQuoteIdentifier", c(class_name, "Id"),
    function(conn, x, ...) {
      barf
      conn@log_call(dbQuoteIdentifier(conn@conn, x, !!! enquos(...)))
    })

  setMethod(
    "dbUnquoteIdentifier", class_name,
    function(conn, x, ...) {
      conn@log_call(dbUnquoteIdentifier(conn@conn, x, !!! enquos(...)))
    })

  setMethod(
    "dbWriteTable", c(class_name, "character", "data.frame"),
    function(conn, name, value, overwrite = FALSE, append = FALSE, ...) {
      conn@log_call(dbWriteTable(conn@conn, name = name, value = value, overwrite = overwrite, append = append, !!! enquos(...)))
    })

  setMethod(
    "dbReadTable", c(class_name, "character"),
    function(conn, name, ...) {
      conn@log_call(dbReadTable(conn@conn, name = name, !!! enquos(...)))
    })

  setMethod(
    "dbListTables", class_name,
    function(conn, ...) {
      conn@log_call(dbListTables(conn@conn, !!! enquos(...)))
    })

  setMethod(
    "dbExistsTable", c(class_name, "character"),
    function(conn, name, ...) {
      conn@log_call(dbExistsTable(conn@conn, name, !!! enquos(...)))
    })

  setMethod(
    "dbListFields", c(class_name, "character"),
    function(conn, name, ...) {
      conn@log_call(dbListFields(conn@conn, name, !!! enquos(...)))
    })

  setMethod(
    "dbRemoveTable", c(class_name, "character"),
    function(conn, name, ...) {
      conn@log_call(dbRemoveTable(conn@conn, name, !!! enquos(...)))
    })

  setMethod(
    "dbGetInfo", class_name,
    function(dbObj, ...) {
      dbObj@log_call(dbGetInfo(dbObj@conn, !!! enquos(...)))
    })

  setMethod(
    "dbBegin", class_name,
    function(conn, ...) {
      conn@log_call(dbBegin(conn@conn, !!! enquos(...)))
    })

  setMethod(
    "dbCommit", class_name,
    function(conn, ...) {
      conn@log_call(dbCommit(conn@conn, !!! enquos(...)))
    })

  setMethod(
    "dbRollback", class_name,
    function(conn, ...) {
      conn@log_call(dbRollback(conn@conn, !!! enquos(...)))
    })

  class_name
}
