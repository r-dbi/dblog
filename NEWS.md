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
