Small, single-`#if CONDITION` preprocessor statements should not add the `/*
CONDITION */` comment to the closing `#endif`.
----

The same rule applies to namespace closures.

This is one of the applications of the more general thumb_ref{cmnt-dry}
principle: We should not document what the code already clearly says.

Original Context:
https://github.com/measurement-factory/squid/pull/20#discussion_r277031498
