Do not catch exceptions that you do not intend to (at least partially)
handle.
----

Let exceptions your code does not handle in any way bubble up naturally,
without passing through your `catch` clauses.

The definition of "handling" itself is very catcher-specific, of course.

Original Context: https://github.com/squid-cache/squid/pull/411#discussion_r290083328
