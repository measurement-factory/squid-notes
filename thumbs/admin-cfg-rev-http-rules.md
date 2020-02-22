When solving reverse proxy caching problems, it is best to fix them using
proper HTTP mechanisms
----

... rather than configuring Squid to violate HTTP.

Using HTTP mechanisms allows all other proxies (and possibly clients) that use
your reverse proxy to benefit from your fixes.

Original Context:
http://lists.squid-cache.org/pipermail/squid-users/2016-April/010236.html
