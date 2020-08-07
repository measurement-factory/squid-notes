# Error Handling

**Service integrity is an absolute requirement**: Squid must not serve
corrupted data, share private information, or ignore access controls. Squid
must preserve service integrity at all costs, terminating transactions,
killing kid processes, or even shutting down the entire instance if necessary.
All decisions or actions must preserve service integrity.

**Service continuity principle**: When facing a problem, a Squid instance
should attempt to recover because recovery is usually overall better than an
instance death (as detailed further below). Needless to say, Squid should use
the best recovery method applicable, from the cached entry removal, to
transaction termination, to kid restart. A restarted kid should provide
essentially the same level of service as its predecessor.

To follow the service continuity principle Squid has to anticipate recovery
attempts. For example, transaction handling code should support abrupt
transaction job termination due to both internal exceptions and external abort
notifications (that may reach the transaction job in any processing stage that
allows notifications to be received). Similarly, interprocess communication
code must handle notifications that can arrive at any time and scrutinize
messages/artifacts that could have been sent/left by a killed transaction or
process.

## Kid restart vs. instance death

A kid restart is usually better than the instance death because a restart
kills fewer transactions, invalidates fewer memory-cached objects, preserves
more of the disk indexing results, and has been the default worker crash
recovery method for decades. Restart downsides (itemized below) have
mitigating factors and usually do not outweigh the positives.

* A freshly restarted worker may be slower at handling a given transaction
  (cold caches, empty memory pools, etc.), but that is mostly an
  implementation deficiency (e.g., Squid could keep caches in shared memory
  and preallocate memory pools) and that deficiency is partially mitigated by
  having to deal with fewer _concurrent_ transactions after a restart.

* A kid restart may "leak" some locked-at-restart-time resources (e.g., some
  locked shared memory or disk cache entries will remain locked until an
  instance death), but the number of such lost resources is normally
  negligible compared to the total amount of resources available to an
  instance.

* Frequent kid restarts may jeopardize Squid instance performance as a whole
  and generate a lot of logging noise. Squid pauses restarts of a hopeless kid
  that experiences frequent failures. If needed, this code should be made
  smarter and/or configurable. For example, some admins may prefer to shut the
  entire crippled Squid service down instead of keep it running with fewer
  workers or diskers.

Administrators of unusual environments that prefer an instance death to kid
restarts should lobby for the corresponding configurable Squid feature.

----

## Exceptions vs. assertions vs. fatal() terminations

TBD: This section needs more work before it will be usable for Squid
development. For now, it just illustrates the multitude of options that a
Squid developer has to pick from when handling a given error, and the negative
effects of the wrong option choice.

C++ static assertions (and other build-failure inducing solutions) are
preferred to all other forms of error detection because they detect the
problem before it can affect a running Squid. Static assertions are preferred
in all contexts where they are possible/supported.

Classic assert() statements are simpler/safer than exceptions and generate
useful core dumps, but limit error recovery to the restart of the asserted kid
process. Assertions must be used when all of the following is true:

* The problem is a Squid implementation bug (rather than invalid input,
  including bad configuration).
* TBD.

Must() exceptions allow the calling code to bypass the problem by terminating
the current transaction, purging (or otherwise making unavailable) the current
cache entry, or disabling the current optional service. Must() exceptions must
be used when all of the following is true:

* The problem is a Squid implementation bug (rather than invalid input,
  including bad configuration).
* TBD.

fatal() calls promise an "orderly" kid exit (with or without a core dump).
Before exiting, the kid process attempts to close most of its listening ports
(if any) and writes clean swap.state logs (if needed). Unfortunately, fatal
interface and implementation have many serious problems:

* Fatal incorrectly assumes that only primary listening ports and UFS caches
  need to participate in orderly shutdown.
* Fatal incorrectly assumes that orderly shutdown is possible while the
  calling chain is in the middle of processing something related to the
  modules being shut down. Calling fatal() and friends often leads to
  unexpected premature core dumps that confuse both system administrators and
  developers.
* Orderly shutdown of all modules is impossible without async calls, but fatal
  implementation does not process the async call queue.
* The FATAL error message is not printed immediately, resulting in confusing
  cache.log output or a complete loss of the message

To avoid most of the above problems, fatal() should only be used by main-level
code and should be avoided in new code. Long-term, this family of functions
should be removed or redesigned.
