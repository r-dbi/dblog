make_log_call <- function(obj_name, log_obj) {
  force(obj_name)
  force(log_obj)

  s4_dict <- collections::Stack()

  find_s4_dict <- function(x) {
    all_s4 <- s4_dict$as_list()
    for (i in seq_along(all_s4)) {
      s4_i <- all_s4[[i]]
      if (identical(s4_i$obj, x)) {
        return(s4_i$name)
      }
    }

    # Not found
    x
  }

  add_s4_dict <- function(x) {
    if (inherits(x, "DBIResult")) prefix <- "res"
    else if (inherits(x, "DBIConnection")) prefix <- "conn"
    else if (inherits(x, "DBIDriver")) prefix <- "drv"
    else return(NULL)

    # Doesn't work yet (?)
    #if (!is.null(find_s4_dict(x))) return(NULL)

    all_s4 <- s4_dict$as_list()
    all_names <- purrr::map_chr(purrr::map(all_s4, "name"), as_string)

    prefix_names <- grep(paste0("^", prefix), all_names, value = TRUE)
    suffixes <- as.integer(gsub(paste0("^", prefix), "", prefix_names))

    max_prefix <- max(c(suffixes, 0L))

    new_name <- as.name(paste0(prefix, max_prefix + 1L))

    s4_dict$push(
      list(
        obj = x,
        name = new_name
      )
    )

    new_name
  }

  clear_s4_dict <- function() {
    s4_dict$clear()
  }


  log_call <- function(call) {
    quo <- enquo(call)
    expr <- quo_get_expr(quo)
    env <- quo_get_env(quo)

    args <- purrr::map(as.list(expr[-1]), ~ eval_tidy(., env = env))
    if (!is.null(obj_name)) {
      args[[1]] <- obj_name
    }

    args <- purrr::map(args, find_s4_dict)
    new_call <- call2(expr[[1]], !!!args)
    result <- NULL
    on.exit(log_obj$log(new_call, result))

    visible_quo <- rlang::new_quosure(call2(withVisible, expr), env)
    result <- eval_tidy(visible_quo)

    new_obj <- add_s4_dict(result$value)
    if (!is.null(new_obj)) {
      new_call <- call2("<-", new_obj, new_call)
      result$value <- wrap(result$value, new_obj, log_obj)
      result$visible <- FALSE
    }

    if (result$visible) {
      result$value
    } else {
      invisible(result$value)
    }
  }

  log_call
}

wrap <- function(x, name, log_obj) {
  if (inherits(x, "DBIDriver")) {
    class_name <- make_driver_class(class(x)[[1]])
    new(class_name, drv = x, log_call = make_log_call(name, log_obj))
  } else if (inherits(x, "DBIConnection")) {
    class_name <- make_connection_class(class(x)[[1]])
    new(class_name, conn = x, log_call = make_log_call(name, log_obj))
  } else if (inherits(x, "DBIResult")) {
    class_name <- make_result_class(class(x)[[1]])
    new(class_name, res = x, log_call = make_log_call(name, log_obj))
  } else {
    abort(paste0("Unknown class: ", paste(class(x), collapse = "/")))
  }
}

make_logger <- function(...) {
  logger <- list2(...)

  logger$log_call <- make_log_call(NULL, logger)
  logger
}

#' Logging parameters
#'
#' TBD.
#'
#' @export
get_default_logger <- function() {
  default_logger
}

format_console <- function(call, result, width = 80) {
  withr::local_options(list(width = width))

  if (is.null(result)) {
    call <- call("try", call)
  }

  # backtick = FALSE gives better results in some edge cases, like
  # list("``" = 1)
  call_fmt <- deparse(call, width.cutoff = width, backtick = FALSE)
  if (isTRUE(result$visible)) {
    output <- capture.output(print(result$value))
    result_fmt <- paste0("## ", output)
  } else {
    result_fmt <- NULL
  }

  paste(c(call_fmt, result_fmt), collapse = "\n")
}

#' @export
#' @param path Passed on to [cat()] for the output.  Default: console output.
#' @rdname get_default_logger
make_text_logger <- function(path = NULL) {
  if (is.null(path)) {
    path <- ""
  }

  make_logger(
    log = function(call, result) {
      cat(format_console(call, result), "\n", sep = "", file = path, append = TRUE)
    }
  )
}

#' @export
#' @rdname get_default_logger
make_collect_logger <- function() {
  queue <- collections::Queue()

  make_logger(
    log = function(call, result) {
      queue$push(format_console(call, result))
    },

    retrieve = function() {
      glue::glue_collapse(as.character(queue$as_list()), sep = "\n")
    }
  )
}

default_logger <- make_text_logger()
