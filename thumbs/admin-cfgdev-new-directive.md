New squid.conf directives should look like this:
----

1. directive name
2. unnamed fixed-position parameter or two; keep this list short!
3. named any-position parameter(s)
4. acl-list; may contain actions

Items 2, 3, and/or 4 do not have to be present/supported.

Some parameters may be optional.

Named parameters have `name=value` syntax. Parameter names use dashes
(`foo-bar`), not snake_case, camelCase, etc. (e.g., not `foo_bar`, `fooBar`,
or `foobar`). Some named parameters may support optional values, becoming just
`name` (but not `name=`).

New directives that accept an optional acl-list should default to "all" or
equivalent (i.e. when no ACLs are specified, they should behave as if the
"all" ACL was specified), but well-justified exceptions to that rule of thumb
are acceptable, and _any_ defaults should be documented.

N.B. Many folks use the words "parameter" and "option" interchangeably and do
not consider "required option" or "optional parameter" to be an oxymoron.
There is no consensus whether Squid should adopt a more strict terminology.

Original Context:
http://lists.squid-cache.org/pipermail/squid-dev/2017-February/008041.html
http://lists.squid-cache.org/pipermail/squid-dev/2017-February/008045.html
http://lists.squid-cache.org/pipermail/squid-dev/2017-February/008046.html
