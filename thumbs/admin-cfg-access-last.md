Make everything work, including SslBump, _before_ customizing http_access
rules.
----

"Everything else" is hard enough to get right on its own, even without all the
common problems related to http_access customizations.

Original Context:
http://lists.squid-cache.org/pipermail/squid-users/2019-August/020877.html
