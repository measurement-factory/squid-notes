`foo.h` should `#include` (directly or indirectly) all headers that are
necessary for compiling `foo.h`.
----

Squid headers should not explicitly `#include` `squid.h` but other Squid
sources must explicitly `#include` `squid.h` as the very first `#include`.

Original Context: A common principle. Inclusion here is inspired by
thumb_ref{macro-include}.
