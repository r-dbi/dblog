
<!-- README.md is generated from README.Rmd. Please edit that file -->

# DBIlog

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/DBIlog)](https://cran.r-project.org/package=DBIlog)
<!-- badges: end -->

The goal of DBIlog is to implement logging for arbitrary DBI backends,
similarly to Perl’s [DBI::Log](https://metacpan.org/pod/DBI::Log). This
is useful for troubleshooting and auditing codes that access a database.
The initial use case for this package is to help debugging DBItest
tests.

## Installation

You can install the released version of DBIlog from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("DBIlog")
```

Install the development version from GitHub using

``` r
# install.packages("devtools")
devtools::install_github("r-dbi/DBIlog")
```

## Basic example

The `LoggingDBI` driver wraps arbitrary drivers:

``` r
library(DBIlog)
drv <- LoggingDBI(RSQLite::SQLite())
#> drv1 <- RSQLite::SQLite()
```

All calls to DBI methods are logged, by default to the console.

``` r
conn <- dbConnect(drv, file = ":memory:")
#> conn1 <- dbConnect(drv1, file = ":memory:")
dbWriteTable(conn, "iris", iris[1:3, ])
#> dbWriteTable(conn1, name = "iris", value = structure(list(Sepal.Length = c(5.1, 4.9, 
#> 4.7), Sepal.Width = c(3.5, 3, 3.2), Petal.Length = c(1.4, 1.4, 1.3), Petal.Width = c(0.2, 
#> 0.2, 0.2), Species = structure(c(1L, 1L, 1L), .Label = c("setosa", "versicolor", 
#> "virginica"), class = "factor")), row.names = c(NA, 3L), class = "data.frame"), overwrite = FALSE, 
#>     append = FALSE)
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

The log is runnable R code\! Run it in a fresh session to repeat the
operations, step by step or in an otherwise controlled fashion.

DBIlog is smart about DBI objects created or returned, and will assign a
new variable name to each new object. Cleared results or closed
connections are not removed automatically.

## Logging options

Logging can be redirected to a file, optionally all outputs may be
logged as well. For example, use a collecting logger to output all calls
and results after the fact.

``` r
collecting_logger <- make_collect_logger()

drv <- LoggingDBI(RSQLite::SQLite(), logger = collecting_logger)
conn <- dbConnect(drv, file = ":memory:")
dbWriteTable(conn, "iris", iris[1:3, ])
data <- dbGetQuery(conn, "SELECT * FROM iris")
dbDisconnect(conn)

collecting_logger$retrieve()
#> drv1 <- RSQLite::SQLite()
#> conn1 <- dbConnect(drv1, file = ":memory:")
#> dbWriteTable(conn1, name = "iris", value = structure(list(Sepal.Length = c(5.1, 4.9, 
#> 4.7), Sepal.Width = c(3.5, 3, 3.2), Petal.Length = c(1.4, 1.4, 1.3), Petal.Width = c(0.2, 
#> 0.2, 0.2), Species = structure(c(1L, 1L, 1L), .Label = c("setosa", "versicolor", 
#> "virginica"), class = "factor")), row.names = c(NA, 3L), class = "data.frame"), overwrite = FALSE, 
#>     append = FALSE)
#> dbGetQuery(conn1, "SELECT * FROM iris")
#> ##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> ## 1          5.1         3.5          1.4         0.2  setosa
#> ## 2          4.9         3.0          1.4         0.2  setosa
#> ## 3          4.7         3.2          1.3         0.2  setosa
#> dbDisconnect(conn1)

ev <- evaluate::evaluate(collecting_logger$retrieve())
cat(unlist(ev, use.names = FALSE), sep = "\n")
#> drv1 <- RSQLite::SQLite()
#> 
#> conn1 <- dbConnect(drv1, file = ":memory:")
#> 
#> dbWriteTable(conn1, name = "iris", value = structure(list(Sepal.Length = c(5.1, 4.9, 
#> 4.7), Sepal.Width = c(3.5, 3, 3.2), Petal.Length = c(1.4, 1.4, 1.3), Petal.Width = c(0.2, 
#> 0.2, 0.2), Species = structure(c(1L, 1L, 1L), .Label = c("setosa", "versicolor", 
#> "virginica"), class = "factor")), row.names = c(NA, 3L), class = "data.frame"), overwrite = FALSE, 
#>     append = FALSE)
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

The full power is demonstrated when running with code where the
underlying *DBI* operations are not obvious:

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

drv <- LoggingDBI(RSQLite::SQLite())
#> drv2 <- RSQLite::SQLite()
conn <- dbConnect(drv, file = ":memory:")
#> conn1 <- dbConnect(drv2, file = ":memory:")
dbWriteTable(conn, "iris", iris[1:3, ])
#> dbWriteTable(conn1, name = "iris", value = structure(list(Sepal.Length = c(5.1, 4.9, 
#> 4.7), Sepal.Width = c(3.5, 3, 3.2), Petal.Length = c(1.4, 1.4, 1.3), Petal.Width = c(0.2, 
#> 0.2, 0.2), Species = structure(c(1L, 1L, 1L), .Label = c("setosa", "versicolor", 
#> "virginica"), class = "factor")), row.names = c(NA, 3L), class = "data.frame"), overwrite = FALSE, 
#>     append = FALSE)

src <- dbplyr::src_dbi(conn)
iris_tbl <- tbl(src, "iris")
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, structure(c(zzz1 = "iris"), class = c("ident", "character"
#> )))
#> ## <SQL> `iris`
#> dbQuoteIdentifier(conn1, "zzz1")
#> ## <SQL> `zzz1`
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, c("", "", ""))
#> ## <SQL> ``
#> ## <SQL> ``
#> ## <SQL> ``
#> res1 <- dbSendQuery(conn1, structure("SELECT *\nFROM `iris` AS `zzz1`\nWHERE (0 = 1)", class = c("sql", 
#> "character")))
#> dbFetch(res1, n = 0)
#> ## [1] Sepal.Length Sepal.Width  Petal.Length Petal.Width  Species     
#> ## <0 rows> (or 0-length row.names)
#> dbClearResult(res1)
iris_tbl %>%
  summarize_if(is.numeric, mean)
#> Applying predicate on the first 100 rows
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, structure("iris", class = c("ident", "character")))
#> ## <SQL> `iris`
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, c("", "", ""))
#> ## <SQL> ``
#> ## <SQL> ``
#> ## <SQL> ``
#> res2 <- dbSendQuery(conn1, structure("SELECT *\nFROM `iris`\nLIMIT 100", class = c("sql", 
#> "character")))
#> dbFetch(res2, n = 100)
#> ##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> ## 1          5.1         3.5          1.4         0.2  setosa
#> ## 2          4.9         3.0          1.4         0.2  setosa
#> ## 3          4.7         3.2          1.3         0.2  setosa
#> dbHasCompleted(res2)
#> ## [1] TRUE
#> dbClearResult(res2)
#> dbQuoteIdentifier(conn1, structure("Sepal.Length", class = c("ident", "character"
#> )))
#> ## <SQL> `Sepal.Length`
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> Warning: Missing values are always removed in SQL.
#> Use `mean(x, na.rm = TRUE)` to silence this warning
#> This warning is displayed only once per session.
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, structure("Sepal.Width", class = c("ident", "character")))
#> ## <SQL> `Sepal.Width`
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, structure("Petal.Length", class = c("ident", "character"
#> )))
#> ## <SQL> `Petal.Length`
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, structure("Petal.Width", class = c("ident", "character")))
#> ## <SQL> `Petal.Width`
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, structure(character(0), class = c("ident", "character")))
#> ## <SQL> 
#> dbQuoteIdentifier(conn1, c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"
#> ))
#> ## <SQL> `Sepal.Length`
#> ## <SQL> `Sepal.Width`
#> ## <SQL> `Petal.Length`
#> ## <SQL> `Petal.Width`
#> dbQuoteIdentifier(conn1, c("", "", "", ""))
#> ## <SQL> ``
#> ## <SQL> ``
#> ## <SQL> ``
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, structure("iris", class = c("ident", "character")))
#> ## <SQL> `iris`
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, c("", "", ""))
#> ## <SQL> ``
#> ## <SQL> ``
#> ## <SQL> ``
#> res3 <- dbSendQuery(conn1, structure("SELECT AVG(`Sepal.Length`) AS `Sepal.Length`, AVG(`Sepal.Width`) AS `Sepal.Width`, AVG(`Petal.Length`) AS `Petal.Length`, AVG(`Petal.Width`) AS `Petal.Width`\nFROM `iris`\nLIMIT 11", class = c("sql", 
#> "character")))
#> dbFetch(res3, n = -1)
#> ##   Sepal.Length Sepal.Width Petal.Length Petal.Width
#> ## 1          4.9    3.233333     1.366667         0.2
#> dbHasCompleted(res3)
#> ## [1] TRUE
#> dbClearResult(res3)
#> # Source:   lazy query [?? x 4]
#> # Database: LoggingDBIConnection
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width
#>          <dbl>       <dbl>        <dbl>       <dbl>
#> 1         4.90        3.23         1.37         0.2
```

The current implementation has limitations, because the connection
objects don’t inherit the underlying classes yet:

``` r
iris_tbl %>%
  summarize_if(is.numeric, mean) %>% 
  explain()
#> Applying predicate on the first 100 rows
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, structure("iris", class = c("ident", "character")))
#> ## <SQL> `iris`
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, c("", "", ""))
#> ## <SQL> ``
#> ## <SQL> ``
#> ## <SQL> ``
#> res4 <- dbSendQuery(conn1, structure("SELECT *\nFROM `iris`\nLIMIT 100", class = c("sql", 
#> "character")))
#> dbFetch(res4, n = 100)
#> ##   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> ## 1          5.1         3.5          1.4         0.2  setosa
#> ## 2          4.9         3.0          1.4         0.2  setosa
#> ## 3          4.7         3.2          1.3         0.2  setosa
#> dbHasCompleted(res4)
#> ## [1] TRUE
#> dbClearResult(res4)
#> <SQL>
#> dbQuoteIdentifier(conn1, structure("Sepal.Length", class = c("ident", "character"
#> )))
#> ## <SQL> `Sepal.Length`
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, structure("Sepal.Width", class = c("ident", "character")))
#> ## <SQL> `Sepal.Width`
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, structure("Petal.Length", class = c("ident", "character"
#> )))
#> ## <SQL> `Petal.Length`
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, structure("Petal.Width", class = c("ident", "character")))
#> ## <SQL> `Petal.Width`
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, structure(character(0), class = c("ident", "character")))
#> ## <SQL> 
#> dbQuoteIdentifier(conn1, c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"
#> ))
#> ## <SQL> `Sepal.Length`
#> ## <SQL> `Sepal.Width`
#> ## <SQL> `Petal.Length`
#> ## <SQL> `Petal.Width`
#> dbQuoteIdentifier(conn1, c("", "", "", ""))
#> ## <SQL> ``
#> ## <SQL> ``
#> ## <SQL> ``
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, structure("iris", class = c("ident", "character")))
#> ## <SQL> `iris`
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, c("", ""))
#> ## <SQL> ``
#> ## <SQL> ``
#> SELECT AVG(`Sepal.Length`) AS `Sepal.Length`, AVG(`Sepal.Width`) AS `Sepal.Width`, AVG(`Petal.Length`) AS `Petal.Length`, AVG(`Petal.Width`) AS `Petal.Width`
#> FROM `iris`
#> 
#> <PLAN>
#> dbQuoteIdentifier(conn1, structure("Sepal.Length", class = c("ident", "character"
#> )))
#> ## <SQL> `Sepal.Length`
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, structure("Sepal.Width", class = c("ident", "character")))
#> ## <SQL> `Sepal.Width`
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, structure("Petal.Length", class = c("ident", "character"
#> )))
#> ## <SQL> `Petal.Length`
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, structure("Petal.Width", class = c("ident", "character")))
#> ## <SQL> `Petal.Width`
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, structure(character(0), class = c("ident", "character")))
#> ## <SQL> 
#> dbQuoteIdentifier(conn1, c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"
#> ))
#> ## <SQL> `Sepal.Length`
#> ## <SQL> `Sepal.Width`
#> ## <SQL> `Petal.Length`
#> ## <SQL> `Petal.Width`
#> dbQuoteIdentifier(conn1, c("", "", "", ""))
#> ## <SQL> ``
#> ## <SQL> ``
#> ## <SQL> ``
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, structure("iris", class = c("ident", "character")))
#> ## <SQL> `iris`
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, c("", ""))
#> ## <SQL> ``
#> ## <SQL> ``
#> dbQuoteIdentifier(conn1, "")
#> ## <SQL> ``
#> dbGetQuery(conn1, structure("EXPLAIN SELECT AVG(`Sepal.Length`) AS `Sepal.Length`, AVG(`Sepal.Width`) AS `Sepal.Width`, AVG(`Petal.Length`) AS `Petal.Length`, AVG(`Petal.Width`) AS `Petal.Width`\nFROM `iris`", class = c("sql", 
#> "character")))
#> ##    addr       opcode p1 p2 p3     p4 p5 comment
#> ## 1     0         Init  0 24  0        00      NA
#> ## 2     1         Null  0  1  8        00      NA
#> ## 3     2     OpenRead  0  2  0      4 00      NA
#> ## 4     3       Rewind  0 17  0        00      NA
#> ## 5     4       Column  0  0  9        00      NA
#> ## 6     5 RealAffinity  9  0  0        00      NA
#> ## 7     6      AggStep  0  9  1 avg(1) 01      NA
#> ## 8     7       Column  0  1  9        00      NA
#> ## 9     8 RealAffinity  9  0  0        00      NA
#> ## 10    9      AggStep  0  9  2 avg(1) 01      NA
#> ## 11   10       Column  0  2  9        00      NA
#> ## 12   11 RealAffinity  9  0  0        00      NA
#> ##  [ reached 'max' / getOption("max.print") -- omitted 14 rows ]
#>    addr       opcode p1 p2 p3     p4 p5 comment
#> 1     0         Init  0 24  0        00      NA
#> 2     1         Null  0  1  8        00      NA
#> 3     2     OpenRead  0  2  0      4 00      NA
#> 4     3       Rewind  0 17  0        00      NA
#> 5     4       Column  0  0  9        00      NA
#> 6     5 RealAffinity  9  0  0        00      NA
#> 7     6      AggStep  0  9  1 avg(1) 01      NA
#> 8     7       Column  0  1  9        00      NA
#> 9     8 RealAffinity  9  0  0        00      NA
#> 10    9      AggStep  0  9  2 avg(1) 01      NA
#> 11   10       Column  0  2  9        00      NA
#> 12   11 RealAffinity  9  0  0        00      NA
#>  [ reached 'max' / getOption("max.print") -- omitted 14 rows ]
```
