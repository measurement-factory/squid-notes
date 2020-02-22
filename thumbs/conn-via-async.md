Before using a Connection object delivered by an AsyncCall, the receiving
code must check that the connection is not closing.
----

The call scheduler (i.e. connection sender) cannot guarantee connection
usability at the future asynchronous call firing time.

XXX: The connection FD may be closed (leaving a stale Connection object
behind) while the AsyncCall is queued unless the AsyncCall itself properly
owns the connection per thumb_ref{conn-close-cb}. None of the existing
AsyncCalls own their connections!

Original Context: A deleted (for irrelevant here reasons) GitHUb comment, but
see its eventual replacement for context:
https://github.com/measurement-factory/squid/pull/37#pullrequestreview-306172339.
