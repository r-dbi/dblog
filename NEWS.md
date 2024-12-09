<!-- NEWS.md is maintained by https://fledge.cynkra.com, contributors should not edit this file -->

# dblog 0.0.0.9026

## Continuous integration

- Avoid failure in fledge workflow if no changes (#28).


# dblog 0.0.0.9025

## Continuous integration

- Fetch tags for fledge workflow to avoid unnecessary NEWS entries (#27).


# dblog 0.0.0.9024

## Continuous integration

- Use larger retry count for lock-threads workflow (#26).


# dblog 0.0.0.9023

## Continuous integration

- Ignore errors when removing pkg-config on macOS (#25).


# dblog 0.0.0.9022

## Continuous integration

- Explicit permissions (#24).


# dblog 0.0.0.9021

## Continuous integration

- Use styler from main branch (#23).


# dblog 0.0.0.9020

## Continuous integration

- Need to install R on Ubuntu 24.04 (#22).

- Trigger run (#16).

- Use Ubuntu 24.04 and styler PR (#20).


# dblog 0.0.0.9019

## Continuous integration

  - Correctly detect branch protection (#19).


# dblog 0.0.0.9018

## Continuous integration

  - Use stable pak (#18).


# dblog 0.0.0.9017

## Continuous integration

  - Trigger run (#17).
    
      - ci: Trigger run
    
      - ci: Latest changes


# dblog 0.0.0.9016

## Continuous integration

  - Trigger run (#16).

  - Use pkgdown branch (#15).
    
      - ci: Use pkgdown branch
    
      - ci: Updates from duckdb


# dblog 0.0.0.9015

## Continuous integration

  - Install via R CMD INSTALL ., not pak (#14).
    
      - ci: Install via R CMD INSTALL ., not pak
    
      - ci: Bump version of upload-artifact action


# dblog 0.0.0.9014

## Chore

  - Auto-update from GitHub Actions.
    
    Run: https://github.com/r-dbi/dblog/actions/runs/10425482998

  - Auto-update from GitHub Actions.
    
    Run: https://github.com/r-dbi/dblog/actions/runs/10200110967

  - Auto-update from GitHub Actions.
    
    Run: https://github.com/r-dbi/dblog/actions/runs/9728444611

  - Auto-update from GitHub Actions.
    
    Run: https://github.com/r-dbi/dblog/actions/runs/9691619402

## Continuous integration

  - Install local package for pkgdown builds.

  - Improve support for protected branches with fledge.

  - Improve support for protected branches, without fledge.

  - Sync with latest developments.

  - Use v2 instead of master.

  - Inline action.

  - Use dev roxygen2 and decor.

  - Fix on Windows, tweak lock workflow.

  - Avoid checking bashisms on Windows.

  - Better commit message.

  - Bump versions, better default, consume custom matrix.

  - Recent updates.


# dblog 0.0.0.9013

- Internal changes only.


# dblog 0.0.0.9012

- Internal changes only.


# dblog 0.0.0.9011

- Internal changes only.


# dblog 0.0.0.9010

- Internal changes only.


# dblog 0.0.0.9009

- Harmonize yaml formatting.

- Revert changes to matrix section.

- Reduce parallelism.

- Also check dev on cran-* branches.

- Update hash key for dev.

- Remove R 3.3.

- Merge pull request #12 from r-dbi/f-safe-deparse.

- Work around problems with names containing backslashes in `deparse()` (#12).

- Work around duckdb storing external pointers in the driver object.

- Add dbCreateTable() and dbAppendTable() methods.


# dblog 0.0.0.9008

- New `dblog_cnr()` (#8).


# dblog 0.0.0.9007

- Add `display` argument to collecting logger to combine printing and collecting (#7).
- Override `dbQuoteString()` for `"SQL"` class.
- Override `dbQuoteLiteral()`.


# dblog 0.0.0.9006

- Dynamic instantiation of S4 classes.
- Failed calls are wrapped with `try()`.


# dblog 0.0.0.9005

- Fix logging output to file, add line break.
- Switch to `deparse(backtick = FALSE)` to create parseable code.
- Fix error when wrapped DBI method fails.


# dblog 0.0.0.9004

- Same as previous version.


# dblog 0.0.0.9003

- Support logging of calls to DBIResult.
- Remove dependency on evaluate package.
- New `make_text_logger()`, renamed from `make_console_logger()`.
- `make_console_logger()` gains `path` argument, is useful again.


# dblog 0.0.0.9001

Initial prototype. Exported functions:

- `dblog()` wraps an arbitrary DBI driver with a custom logger.
- `get_default_logger()` is the default console logger. 
- `make_console_logger()` creates a new console logger (for internal use only).
- `make_collect_logger()` creates a new logger that collects logging output and emits all at once.
