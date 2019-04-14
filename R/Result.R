#' @include Connection.R
NULL

setClass("LoggingDBIResult")

make_result_class <- function(base_class) {

  template_name <- "LoggingDBIResult"
  class_name <- paste0(template_name, "-", base_class)
  all_base_classes <- c(template_name, base_class)

  if (isClass(class_name)) {
    return(class_name)
  }

  class <- setClass(class_name,
    contains = all_base_classes, slots = list(res = base_class, log_call = "function"))

  setMethod(
    "show", class_name,
    function(object) {
      cat("<LoggingDBIResult>\n")
      show(object@res)
    })

  setMethod(
    "dbClearResult", class_name,
    function(res, ...) {
      res@log_call(dbClearResult(res@res, !!! enquos(...)))
    })

  setMethod(
    "dbFetch", class_name,
    function(res, n = -1, ...) {
      res@log_call(dbFetch(res@res, n = n, !!! enquos(...)))
    })

  setMethod(
    "dbHasCompleted", class_name,
    function(res, ...) {
      res@log_call(dbHasCompleted(res@res, !!! enquos(...)))
    })

  setMethod(
    "dbGetInfo", class_name,
    function(dbObj, ...) {
      dbObj@log_call(dbGetInfo(dbObj@res, !!! enquos(...)))
    })

  setMethod(
    "dbIsValid", class_name,
    function(dbObj, ...) {
      dbObj@log_call(dbIsValid(dbObj@res, !!! enquos(...)))
    })

  setMethod(
    "dbGetStatement", class_name,
    function(res, ...) {
      res@log_call(dbGetStatement(res@res, !!! enquos(...)))
    })

  setMethod(
    "dbColumnInfo", class_name,
    function(res, ...) {
      res@log_call(dbColumnInfo(res@res, !!! enquos(...)))
    })

  setMethod(
    "dbGetRowCount", class_name,
    function(res, ...) {
      res@log_call(dbGetRowCount(res@res, !!! enquos(...)))
    })

  setMethod(
    "dbGetRowsAffected", class_name,
    function(res, ...) {
      res@log_call(dbGetRowsAffected(res@res, !!! enquos(...)))
    })

  setMethod(
    "dbBind", class_name,
    function(res, params, ...) {
      res@log_call(dbBind(res@res, params, !!! enquos(...)))
      invisible(res)
    })

  class_name
}
