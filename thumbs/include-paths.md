All `src/` header files should be included using paths relative to `src`.
----

When already in `src/foo/`, writing `#include "f.h"` to include `src/foo/f.h`
is tempting and will, sometimes, work. However, to improve code search-ability
and maintainability as well as to reduce unintended header clashes, use
`#include "foo/f.h"`.

Squid guarantees header name uniqueness only when that name has a proper path.

For header files located in the `src/` directory itself, do not use any path:
`#include "g.h"`.

Original Context: A private review.
