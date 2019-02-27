make_log_call <- function(obj_name) {
  force(obj_name)

  s4_dict <- collections::Stack$new()

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

    args <- purrr::map(expr[-1], ~ eval_tidy(., env))
    if (!is.null(obj_name)) {
      args[[1]] <- obj_name
    }

    args <- purrr::map(args, find_s4_dict)
    new_call <- call2(expr[[1]], !!!args)
    #on.exit(print(styler::style_text(deparse(new_call, width.cutoff = 80))))
    on.exit({
      cat(deparse(new_call, width.cutoff = 80), sep = "\n")
      if (isTRUE(result$visible)) {
        ev <- evaluate::evaluate(
          result$value
        )
        cat(
          paste0(
            "## ",
            strsplit(ev[[2]], "\n")[[1]]
          ),
          sep = "\n"
        )
      }
    })

    visible_quo <- rlang::new_quosure(call2(withVisible, expr), env)
    result <- eval_tidy(visible_quo)

    new_obj <- add_s4_dict(result$value)
    if (!is.null(new_obj)) {
      new_call <- call2("<-", new_obj, new_call)
      result$value <- wrap(result$value, new_obj)
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

wrap <- function(x, name) {
  if (inherits(x, "DBIDriver")) {
    new("LoggingDBIDriver", drv = x, log_call = make_log_call(name))
  } else if (inherits(x, "DBIConnection")) {
    new("LoggingDBIConnection", conn = x, log_call = make_log_call(name))
  } else if (inherits(x, "DBIResult")) {
    new("LoggingDBIResult", res = x, log_call = make_log_call(name))
  } else {
    abort(paste0("Unknown class: ", paste(class(x), collapse = "/")))
  }
}

#' Create a logger object
#'
#' TBD.
#'
#' @export
logger <- function() {
  make_log_call(NULL)
}

default_logger <- logger()

#' @export
#' @rdname logger
get_default_logger <- function() {
  default_logger
}
