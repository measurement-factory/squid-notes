If you have to change a source code line for some PR-related reason, then do
apply basic cleanup changes as well (e.g., HERE removal and NULL
replacement).
----

This rule does not apply to automated source code changes, of course. Scripts
may polish what they change if it is easy to do so, but it is unreasonable to
expect every source code formatting or modernizing script to make every
polishing touch a human would apply.

See also: thumb_ref{pr-polish-unchanged}.

Original Context:
http://bugs.squid-cache.org/show_bug.cgi?id=4857#c7
