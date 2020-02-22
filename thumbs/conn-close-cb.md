A Comm::Connection owner must maintain a closing callback.
----

Even with a closing handler, the owner has to tolerate a _closing_ connection,
but without callback, the underlying FD may be closed without job's knowledge,
leaving a stale/out-of-sync Connection::fd value behind. The later state
_cannot_ be reliably detected be the owner and leads to low-level assertions,
crashes, information leaks, etc.

Original Context:
https://github.com/squid-cache/squid/pull/489#discussion_r377775116
