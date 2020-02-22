A macro-using code that can be compiled even if that macro is undefined must
explicitly `#include` the header providing that macro.
----

Relying on _indirect_ inclusion is too risky here because the list of
indirectly included headers may be changed by those who do not know about this
hidden dependency.

The `squid.h` header provides ./configure-driven feature-test macros (e.g.,
`USE_OPENSSL` or `HAVE_GSSAPI`) that any source code file can count on.

Original Context:
https://github.com/squid-cache/squid/pull/369#discussion_r259392784
