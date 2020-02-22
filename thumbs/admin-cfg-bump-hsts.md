If you are splicing a domain, then never bump it. If you want to bump it,
then neither splice it nor allow any other ways to reach it except through
the bumping proxy.
----

It is technically possible to transition a domain from being spliced/relayed
to bumped, but it can be a painful process involving a lot of unavoidable TLS
related "errors" for clients during the transition timeout dictated by the
HSTS header and/or similar things.

Original Context:
http://lists.squid-cache.org/pipermail/squid-users/2017-November/016883.html
