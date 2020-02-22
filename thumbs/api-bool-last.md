Put boolean data members last.
----

This rule often reduces padding and might help enable some low-level compiler
optimizations. The rule is not meant for classes that have only a few
concurrent instances where other design concerns probably outweigh padding.

Original Context:
http://lists.squid-cache.org/pipermail/squid-dev/2016-January/004680.html
