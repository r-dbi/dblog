
<!-- README.md and index.md are generated from README.Rmd.
     Edit that file and render it the usual way: rmarkdown::render(), devtools::build_readme(), or the Knit button.
     The cynkratemplate package must be installed; it supplies the output format. -->

# dblog

<!-- badges: start -->

[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN status](https://www.r-pkg.org/badges/version/dblog)](https://cran.r-project.org/package=dblog)
<!-- badges: end -->

The goal of dblog is to implement logging for arbitrary DBI backends, similarly to Perl's [DBI::Log](https://metacpan.org/pod/DBI::Log).
This is useful for troubleshooting and auditing codes that access a database.
The initial use case for this package is to help debugging DBItest tests.

## Installation

You can install the released version of dblog from [CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("dblog")
```

Install the development version from GitHub using

``` r
# install.packages("devtools")
devtools::install_github("r-dbi/dblog")
```

## Basic example

The `dblog` driver wraps arbitrary drivers:

``` r
library(dblog)
drv <- dblog(RSQLite::SQLite())
#> drv1 <- new("SQLiteDriver")
```

All calls to DBI methods are logged, by default to the console.

``` r
conn <- dbConnect(drv, file = ":memory:")
#> conn1 <- dbConnect(drv1, file = ":memory:")
dbWriteTable(conn, "iris", iris[1:3, ])
#> dbWriteTable(conn1, name = "iris", value = structure(list(c(5.1, 4.9, 4.7), c(3.5, 
#> 3, 3.2), c(1.4, 1.4, 1.3), c(0.2, 0.2, 0.2), structure(c(1L, 1L, 1L), levels = c("setosa", 
#> "versicolor", "virginica"), class = "factor")), names = c("Sepal.Length", "Sepal.Width", 
#> "Petal.Length", "Petal.Width", "Species"), row.names = c(NA, 3L), class = "data.frame"), 
#>     overwrite = FALSE, append = FALSE)
data <- dbGetQuery(conn, "SELECT * FROM iris")
#> dbGetQuery(conn1, "SELECT * FROM iris")
#> ##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> ## 1          5.1         3.5          1.4         0.2  setosa
#> ## 2          4.9         3.0          1.4         0.2  setosa
#> ## 3          4.7         3.2          1.3         0.2  setosa
dbDisconnect(conn)
#> dbDisconnect(conn1)

data
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> 1          5.1         3.5          1.4         0.2  setosa
#> 2          4.9         3.0          1.4         0.2  setosa
#> 3          4.7         3.2          1.3         0.2  setosa
```

The log is runnable R code!
Run it in a fresh session to repeat the operations, step by step or in an otherwise controlled fashion.

dblog is smart about DBI objects created or returned, and will assign a new variable name to each new object.
Cleared results or closed connections are not removed automatically.

## Logging options

Logging can be redirected to a file, optionally all outputs may be logged as well.
For example, use a collecting logger to output all calls and results after the fact.

``` r
collecting_logger <- make_collect_logger()

drv <- dblog(RSQLite::SQLite(), logger = collecting_logger)
conn <- dbConnect(drv, file = ":memory:")
dbWriteTable(conn, "iris", iris[1:3, ])
data <- dbGetQuery(conn, "SELECT * FROM iris")
dbDisconnect(conn)

collecting_logger$retrieve()
#> drv1 <- new("SQLiteDriver")
#> conn1 <- dbConnect(drv1, file = ":memory:")
#> dbWriteTable(conn1, name = "iris", value = structure(list(c(5.1, 4.9, 4.7), c(3.5, 
#> 3, 3.2), c(1.4, 1.4, 1.3), c(0.2, 0.2, 0.2), structure(c(1L, 1L, 1L), levels = c("setosa", 
#> "versicolor", "virginica"), class = "factor")), names = c("Sepal.Length", "Sepal.Width", 
#> "Petal.Length", "Petal.Width", "Species"), row.names = c(NA, 3L), class = "data.frame"), 
#>     overwrite = FALSE, append = FALSE)
#> dbGetQuery(conn1, "SELECT * FROM iris")
#> ##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> ## 1          5.1         3.5          1.4         0.2  setosa
#> ## 2          4.9         3.0          1.4         0.2  setosa
#> ## 3          4.7         3.2          1.3         0.2  setosa
#> dbDisconnect(conn1)

ev <- evaluate::evaluate(collecting_logger$retrieve())
cat(unlist(ev, use.names = FALSE), sep = "\n")
#> drv1 <- new("SQLiteDriver")
#> 
#> conn1 <- dbConnect(drv1, file = ":memory:")
#> 
#> dbWriteTable(conn1, name = "iris", value = structure(list(c(5.1, 4.9, 4.7), c(3.5, 
#> 3, 3.2), c(1.4, 1.4, 1.3), c(0.2, 0.2, 0.2), structure(c(1L, 1L, 1L), levels = c("setosa", 
#> "versicolor", "virginica"), class = "factor")), names = c("Sepal.Length", "Sepal.Width", 
#> "Petal.Length", "Petal.Width", "Species"), row.names = c(NA, 3L), class = "data.frame"), 
#>     overwrite = FALSE, append = FALSE)
#> 
#> dbGetQuery(conn1, "SELECT * FROM iris")
#> 
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> 1          5.1         3.5          1.4         0.2  setosa
#> 2          4.9         3.0          1.4         0.2  setosa
#> 3          4.7         3.2          1.3         0.2  setosa
#> 
#> ##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> 
#> ## 1          5.1         3.5          1.4         0.2  setosa
#> 
#> ## 2          4.9         3.0          1.4         0.2  setosa
#> 
#> ## 3          4.7         3.2          1.3         0.2  setosa
#> 
#> dbDisconnect(conn1)
```

## Logging complex operations

The full power is demonstrated when running with code where the underlying *DBI* operations are not obvious:

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

drv <- dblog(RSQLite::SQLite())
#> drv2 <- new("SQLiteDriver")
conn <- dbConnect(drv, file = ":memory:")
#> conn1 <- dbConnect(drv2, file = ":memory:")
dbWriteTable(conn, "iris", iris[1:3, ])
#> dbWriteTable(conn1, name = "iris", value = structure(list(c(5.1, 4.9, 4.7), c(3.5, 
#> 3, 3.2), c(1.4, 1.4, 1.3), c(0.2, 0.2, 0.2), structure(c(1L, 1L, 1L), levels = c("setosa", 
#> "versicolor", "virginica"), class = "factor")), names = c("Sepal.Length", "Sepal.Width", 
#> "Petal.Length", "Petal.Width", "Species"), row.names = c(NA, 3L), class = "data.frame"), 
#>     overwrite = FALSE, append = FALSE)

src <- dbplyr::src_dbi(conn)
iris_tbl <- tbl(src, "iris")
#> dbGetQuery(conn1, structure("SELECT *\nFROM `iris` AS `q01`\nWHERE (0 = 1)", class = c("sql", 
#> "character")))
#> ## [1] Sepal.Length Sepal.Width  Petal.Length Petal.Width  Species     
#> ## <0 rows> (or 0-length row.names)
iris_tbl %>%
  summarize_if(is.numeric, mean)
#> Applying predicate on the first 100 rows
#> res1 <- dbSendQuery(conn1, structure("SELECT *\nFROM `iris`\nLIMIT 100", class = c("sql", 
#> "character")))
#> dbFetch(res1, n = 100)
#> ##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> ## 1          5.1         3.5          1.4         0.2  setosa
#> ## 2          4.9         3.0          1.4         0.2  setosa
#> ## 3          4.7         3.2          1.3         0.2  setosa
#> dbHasCompleted(res1)
#> ## [1] TRUE
#> dbClearResult(res1)
#> Warning: Missing values are always removed in SQL aggregation functions.
#> Use `na.rm = TRUE` to silence this warning
#> This warning is displayed once every 8 hours.
#> res2 <- dbSendQuery(conn1, structure("SELECT\n  AVG(`Sepal.Length`) AS `Sepal.Length`,\n  AVG(`Sepal.Width`) AS `Sepal.Width`,\n  AVG(`Petal.Length`) AS `Petal.Length`,\n  AVG(`Petal.Width`) AS `Petal.Width`\nFROM `iris`\nLIMIT 21", class = c("sql", 
#> "character")))
#> dbFetch(res2, n = -1)
#> ##   Sepal.Length Sepal.Width Petal.Length Petal.Width
#> ## 1          4.9    3.233333     1.366667         0.2
#> dbHasCompleted(res2)
#> ## [1] TRUE
#> dbClearResult(res2)
#> # A query:  ?? x 4
#> # Database: sqlite 3.53.4 []
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width
#>          <dbl>       <dbl>        <dbl>       <dbl>
#> 1          4.9        3.23         1.37         0.2
```

## Inheritance hierarchy

Despite the common suggestion to [prefer composition over inheritance](https://en.wikipedia.org/wiki/Composition_over_inheritance),
the new logging classes are implemented as subclasses of the actual DBI classes.
Moreover, the class definitions are created on demand: for each different database backend, different subclasses are defined,
to make sure dispatch is routed to the right methods.

The reason for this is that other methods, unknown to this package, might dispatch on the DBI class.
One such example is *dbplyr* that introduces specialized behaviors for many classes.
The `explain()` method calls the internal `db_explain()` method
which uses `EXPLAIN QUERY PLAN` for SQLite connections but `EXPLAIN` for unspecified database connections.
Without inheritance, *dbplyr* would use the default method.
This might lead to errors for other databases that do not understand `EXPLAIN`.

``` r
iris_tbl %>%
  summarize_if(is.numeric, mean) %>% 
  explain()
#> Applying predicate on the first 100 rows
#> res3 <- dbSendQuery(conn1, structure("SELECT *\nFROM `iris`\nLIMIT 100", class = c("sql", 
#> "character")))
#> dbFetch(res3, n = 100)
#> ##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> ## 1          5.1         3.5          1.4         0.2  setosa
#> ## 2          4.9         3.0          1.4         0.2  setosa
#> ## 3          4.7         3.2          1.3         0.2  setosa
#> dbHasCompleted(res3)
#> ## [1] TRUE
#> dbClearResult(res3)
#> <SQL>
#> SELECT
#>   AVG(`Sepal.Length`) AS `Sepal.Length`,
#>   AVG(`Sepal.Width`) AS `Sepal.Width`,
#>   AVG(`Petal.Length`) AS `Petal.Length`,
#>   AVG(`Petal.Width`) AS `Petal.Width`
#> FROM `iris`
#> 
#> <PLAN>
#> dbGetQuery(conn1, structure("EXPLAIN QUERY PLAN SELECT\n  AVG(`Sepal.Length`) AS `Sepal.Length`,\n  AVG(`Sepal.Width`) AS `Sepal.Width`,\n  AVG(`Petal.Length`) AS `Petal.Length`,\n  AVG(`Petal.Width`) AS `Petal.Width`\nFROM `iris`", class = c("sql", 
#> "character")))
#> ##   id parent notused    detail
#> ## 1  3      0     216 SCAN iris
#>   id parent notused    detail
#> 1  3      0     216 SCAN iris
```

------------------------------------------------------------------------

Please note that the 'dblog' project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md).
By contributing to this project, you agree to abide by its terms.
