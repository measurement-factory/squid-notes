In a performance-sensitive setup, the startup=n value for a given helper
should correspond to the maximum number of those helpers actually used when
handling normal day-to-day traffic.
----

While starting as many helpers as are necessary during a DoS attack may be an
overkill, waiting for the load to increase before starting a reasonable number
of helpers is counter-productive because leads to excessive transaction
response times when the load naturally goes up.

Original Context:
http://lists.squid-cache.org/pipermail/squid-users/2018-April/018071.html
