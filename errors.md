# Error Handling

As any complex software, Squid has to _balance_ basic service requirements:
integrity/functionality, availability/continuity, performance, resource
utilization, etc. Satisfying any one requirement in isolation is trivial but
meaningless (e.g., the service integrity can be guaranteed by simply refusing
to provide any service). This page documents how Squid balances these
requirements when handling errors, especially Squid bugs.

## Recover or die

When Squid discovers an internal error or bug, Squid must kill (or stop using)
the affected component instance because continuing using the compromised
component is either technically impossible (i.e. there is no code that can
bypass the discovered problem) or likely to result in service integrity
violations (e.g., sending a corrupted HTTP response to the client).

After killing a compromised component instance, Squid may have a choice of
whether to revive the component (i.e. start another component instance to
replace the killed one). The correct decision depends on whether a restartable
component is deemed optional or essential.

* When a component was explicitly enabled or added by the admin and not
  configured as optional, Squid should assume it is essential (from the admin
  point of view).

Essential components should be revived because providing a service without an
essential component would violate Squid functionality requirements. If those
revival attempts are unsuccessful, impossible, too costly, too risky, etc.,
then the encompassing component must be restarted instead (for the same
reason). If the problem bubbles up to the level of the entire Squid instance,
the instance must quit.

By definition, optional components may be disabled or bypassed (after no,
fewer, or less persistent recovery attempts) without essential functionality
loss.

To prevent resource exhaustion and integrity violations, the resources used by
a killed component must be freed, released, and/or invalidated. This
requirement is only partially implemented (TODO: Formalize cataloging of the
transaction-associated resources and implement their safe cleanup during a kid
death).

A revived component instance should provide essentially the same level of
service as its predecessor.

If a bug affects multiple components, the above reasoning applies to each of
the affected components.

Here are a few examples of major Squid components and the corresponding bug
handling methods:

* A Squid instance: Represents shared global state of all SMP kid processes.
  The OS may be configured to restart aborted Squid instances, but there is
  currently no internal mechanism to explicitly abort an instance (TODO).
  Until that mechanism is implemented, the largest component that can be
  explicitly aborted is a kid process (see below). A Squid instance will quit
  if it cannot keep at least one kid running. Since kids are essential, this
  is a Squid bug: Instead, a Squid instance must quit if it cannot keep _all_
  kids running.

* A kid process: Represents a single OS process state. Assertions (and
  equivalent constructs) kill kid processes. Squid instance restarts killed
  kids.

* A helper: Represents the state associated with an external kid-started
  process providing a particular service to the kid process via stdin/stdout
  communication. There are Squid APIs for terminating helper instances. Kids
  replace their terminated helper instances with new ones if/as needed.

* A Store entry: Represents an HTTP response and associated metadata. Some
  entries are written to Squid cache, some are read from Squid cache, some are
  used to feed client transaction(s), and some serve in several (or all of the
  above) roles. Squid Store APIs can make an entry unusable and/or unsharable
  by transactions as well as to purge an entry from the cache.

* A composite (aggregate or compounded) transaction: Represents a collection
  of various protocol transactions working towards satisfying a single
  external request (or an equivalent independently generated internal
  request). There are currently no APIs to kill composite transactions, but
  they usually die when one of the protocol transactions comprising the
  composite dies.

* A protocol transaction: Represents a collection of resources and state
  associated with a single HTTP, ICAP, eCAP, DNS, etc. request or query,
  received or sent (including the response(s) to that query). Protocol
  transactions usually end when one of the corresponding async job ends and/or
  the corresponding transport socket is closed.

To provide service continuity, Squid code has to anticipate component deaths
and recovery attempts. For example, transaction handling code should support
abrupt transaction job termination due to both internal exceptions and
external abort notifications (that may reach the transaction job in any
processing stage that allows notifications to be received). Similarly,
interprocess communication code must handle notifications that can arrive at
any time and scrutinize messages/artifacts that could have been sent/left by a
killed transaction or process.


### Case study: Kid restart vs. Squid instance death

A kid restart is usually better than the instance death because a restart
kills fewer transactions, invalidates fewer memory-cached objects, preserves
more of the disk indexing results, and has been the default worker crash
recovery method for decades. Restart downsides (itemized below) have
mitigating factors and usually do not outweigh the positives.

* An aborted kid may leave behind a corrupted Store entry (being written by
  the aborted kid) that other kids may be reading, but even an instance
  restart cannot fully prevent such corruption propagation because such
  corruption is usually discovered after the fact, when other kids could have
  read the entry already. TODO: The worker killing and/or recovery procedure
  can and should invalidate entries abandoned by writers in the killed worker.

* An aborted kid may leave behind incomplete Store entries (being written by
  the aborted kid) that other kids may be waiting on, leading to timeouts, but
  the number of such timeouts ought to be relatively small compared to the
  total number of transactions an instance death would kill. TODO: The
  recovery procedure can and should inform affected kids about aborted entry
  writers.

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

## Invariant checks: Exceptions vs. assertions

This section answers a simple question: Should the bulk of Squid code use
abort()-calling assertions or exception-throwing expressions for validating
invariants? The correct answer is "use exception-throwing expressions".

Many C++ guides and gurus advocate _asserting_ invariants and argue against
throwing exceptions upon discovering a bug (a.k.a. a program logic error). For
example, [Herb Sutter] says that "Programs bugs are not recoverable run-time
errors and so should not be reported as exceptions".

[Herb Sutter]:
  http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2019/p0709r4.pdf
  "4.2 Proposed cleanup: Don’t report logic errors using exceptions"

These ideas share the same basic logic: There is no point in throwing an
exception upon discovering a bug because there is no way to _recover_ from
that exception (that would still assure reasonable service integrity). Thus,
the buggy program must die.

This logic can be useful for toy models, but its blind application may lead to
poor results, especially when it comes to complex server software like Squid.
If we discard the "buggy programs should not be used" extreme as impractical
(in Squid application domain), then these recommendations assume that
restarting a buggy program is the best solution. That assumption is correct
for most programs that serve a single transaction at a time and lack
persistent state, but it is wrong for many other real-world cases, including
Squid.

For example, restarting a program that maintains persistent state across
restarts (e.g., on disk and/or in shared memory) may not be enough to clear
the bad state. And if we cannot _guarantee_ full recovery after discovering a
bug, then we cannot claim that a restart is always the _best_ option,
especially when a restart itself has high costs (e.g., kills thousands of
unaffected transactions and/or rejects new transaction for a long time).

These real-world concerns probably explain why C++ experts like N. Myers and
B. Stroustrup as well as proposed C++ standards consider supporting _throwing_
violation handlers in [contract based programming].

[contract based programming]:
  http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2018/p0542r4.html
  "2.8 Throwing violation handler"

If Squid code must use assertions, then each bug would result in a kid
restart. Historically, for the vast majority of bugs, such harsh bug handling
strategy would be an overkill! Knowing that, many developers will violate the
assert-on-bug guidelines or, worse, hesitate adding useful invariant checks to
avoid discussions like [Squid change request 627407496].

[Squid change request 627407496]:
  https://github.com/squid-cache/squid/pull/795#pullrequestreview-627407496
  "Can we use Must() instead of assert() for these checks?"

Thus, Squid code should usually throw when an invariant is violated.

What about the rare bugs that affect the entire kid or even the entire Squid
instance state? Using assertions for these bugs is not a good idea either
because doing so would force developers to decide whether a given invariant is
"local" (throw) or "global" (assert) in nature -- an often impossible choice,
especially in low-level code! Moreover, asserting will still not help with
clearing Squid instance-wide state stored in shared memory or on disk. Most
likely, any rare code entering such sensitive "global" areas would have to set
up appropriate cleanup routines that will be automatically triggered by the
propagated exception.

Combined, the above reasoning leads to the following conclusion:

* Squid code should throw when an invariant is violated.

## Invariant checks: Missing API

Until [contract based programming] (with exceptions support) becomes a
reality, there is no standard, exception-throwing API for checking invariants.
Squid offers Must(), but Must() is currently not suitable for this purpose
because Must() violations are not reported (by default). We should not hide
bugs!

|  API   | Source          | Reported | Scope     | Optional |
|:------:|:---------------:|:--------:|:---------:|:--------:|
|assert()| `<cassert>`     |  yes     |  kid      |  NDEBUG  |
|Assert()| TODO?           |  yes     | component |  NDEBUG  |
|Must()  |`TextException.h`|  no      | component |  no      |

Wrong "killing radius" or "scope" disqualifies the standard assert() as well,
as detailed in the previous section.

Thus, we need a new API like the Assert() macro sketched above or we need to
change Must() to be like Assert() (and then rework some of the current Must()
callers).

Side note: AFAICT, when Must() was first introduced into the Squid project
(Squid master commit `774c051`), it was meant to be used like Assert(), but it
was not _implemented_ as such and, hence, developers found it very convenient
for input validation, expanding its scope.

Today, there are some 900 Must()s in Squid code. The vast majority of Must()s
are used like Assert(), but their blind conversion to Assert() semantics would
probably result in too many level-0 cache.log messages due to input validation
use cases. Given the lack of resources to carefully examine each Must()
caller, only a (slow) migration to a new API can solve the reporting problem.

Until Assert() is available, it may be a good idea to use assert() in new code
because, unlike the effectively dual-purpose Must() macro, assert() calls
would be easier to convert to Assert() when the time comes.


## Problems with fatal()

Squid fatal() calls promise an "orderly" kid exit (with or without a core
dump). Before exiting, the kid process attempts to close most of its listening
ports (if any) and writes clean swap.state logs (if needed). Unfortunately,
fatal interface and implementation have many serious problems:

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
  cache.log output or a complete loss of the message.

To avoid most of the above problems, fatal() should only be used by main-level
code and should be avoided in new code. Long-term, this family of functions
should be removed or redesigned.
