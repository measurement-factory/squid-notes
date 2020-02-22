When there is an alternative, avoid regular expressions.
----

Regular expressions are relatively slow and may be difficult to interpret
correctly. If you can easily fulfill your requirements with a directive that
uses exact string matching (or an equivalent matching without any regular
expressions), then go with that directive.

On the other hand, avoid replacing one simple regular expression with 1000
exact string matches, of course.

See also: thumb_ref{admin-cfg-merge-refresh}.

Original Context:
http://lists.squid-cache.org/pipermail/squid-users/2017-September/016453.html
