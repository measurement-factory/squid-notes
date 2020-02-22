Library-agnostic APIs (e.g., `Security`) must be the same, regardless of the
library Squid is being compiled with.
----

The implementation of those Library-agnostic APIs may depend on the library,
of course. For example, it is also perfectly fine for GnuTLS-specific code to
use types that are different from types used by OpenSSL-specific code.
However, the library-agnostic APIs must remain the same.

For example, adding or relying on something like this is a bad idea:

```C++
namespace Security {
#if USE_OPENSSL
    typedef LockingPointer<...> SessionPointer;
#elif USE_GNUTLS
    typedef TidyPointer<...> SessionPointer;
#endif
};
```

... unless LockingPointer and TidyPointer have the same API.

Violating this rule leads to library-agnostic code that compiles and works
fine with one library but either does not compile or, worse, does not work
with the other library.


Original Context:
http://lists.squid-cache.org/pipermail/squid-dev/2016-June/006015.html
