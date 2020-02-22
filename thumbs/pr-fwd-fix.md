If an existing `forward.h` file is missing a forward declaration, please fix
that file (instead of forward-declaring elsewhere).
----

Adding a new `forward.h` file to an existing `src` subdirectory is also a good
idea (assuming your pull request requires declarations provided by the library
in that directory). Unfortunately, dealing with forward declarations in `src`
files is more challenging -- we want to move those files away from `src`
rather than gobble all their forward declarations in `src/forward.h`.

Original Context:
http://lists.squid-cache.org/pipermail/squid-dev/2017-January/007811.html
