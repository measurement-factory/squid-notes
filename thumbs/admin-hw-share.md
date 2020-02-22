When running SMP Squid or multiple Squid instances that share underlying
hardware:
----

1. Ensure that cache_dirs (if any) do not share physical disk spindles. This
   can be tricky in virtualized environments, but failure to do so leads to
   serious performance degratations and shortened disk lifetimes (because disk
   I/O contention causes controller issues).

2. Ensure that busy Squids (or SMP workers) do not share their CPU core with
   other services. Hyperthreading is nearly useless in this context.

3. Avoid VM overheads if possible. Consider using containers instead.

4. Avoid NTLM. It doubles the traffic load on the frontend compared to any
   other auth type.

Original Context:
http://lists.squid-cache.org/pipermail/squid-users/2016-August/011765.html
