### Architectural principles

thumbX: When an owner of a Comm::Connection object decides that it is time to
close the underlying transport connection, that owner should call
Comm::Connection::close().

Original Context:
https://github.com/squid-cache/squid/pull/489#discussion_r377775116


thumbX: a Comm::Connection owner must maintain a closing callback. Even with a
closing handler, the owner has to tolerate a _closing_ connection, but without
callback, the underlying FD may be closed without job's knowledge, leaving a
stale/out-of-sync Connection::fd value behind. The later state _cannot_ be
reliably detected be the owner and leads to low-level assertions, crashes,
information leaks, etc.

Original Context:
https://github.com/squid-cache/squid/pull/489#discussion_r377775116


thumbX: Manual fixes affecting a lot of code with no functionality changes are
usually not worth their (total) cost [because they cannot be easily repeated
30 times for 30 branches].

Original Context: http://bugs.squid-cache.org/show_bug.cgi?id=5021#c27


thumbX: When reporting various errors, bugs, and problems:

1. Level-0/1 messages should be used for important events affecting the Squid
   instance as a whole (e.g., (suspected) serious Squid bugs,
   misconfigurations, and attacks).
2. Individual transaction failures (that do not qualify as important events in
   item 1) should be reflected in access.log records.
3. Level-0/1 messages that may be logged frequently (e.g., those that may be
   triggered by incoming data) should have a reporting limit. In other words,
   Squid should stop reporting them after a while or, better, rate-limit such
   reports.

This rule reduces chances that admins stop paying attention to important
cache.log messages because the cache.log is dominated by
irrelevant-to-the-admin noise and/or relevant-but-overwhelming info. The rule
also prevents DoS attacks via excessive cache.log logging.

Original Context:
https://github.com/squid-cache/squid/pull/411#discussion_r362064319
https://github.com/squid-cache/squid/pull/411#discussion_r382656921

thumbX: The rule of thumb for safe string view usage is that the lifetime of
any view storage should not exceed the lifetime of the originating string.

Original Context:
https://github.com/squid-cache/squid/pull/481#discussion_r361757292


thumbX: Before using a Connection object delivered by an AsyncCall, the
receiving code must check that the connection is not closing. The call
scheduler (i.e. connection sender) cannot guarantee connection usability at
the future asynchronous call firing time.

XXX: The connection FD may be closed (leaving a stale Connection object
behind) while the AsyncCall is queued unless the AsyncCall itself properly
owns the connection per thumbW. None of the existing AsyncCalls own their
connections!

Original Context: A deleted (for irrelevant here reasons) GitHUb comment, but
see its eventual replacement for context:
https://github.com/measurement-factory/squid/pull/37#pullrequestreview-306172339.



thumbX: Destruction/closure/etc. is always safe (and is always a no-op if
repeated) -- no checks should be needed in the caller. For example, do not
write `if (x.open()) x.close()`; just say `x.close()`. Similarly, do not write
`if (x) delete x`; just say `delete x`.

Original Context: https://github.com/measurement-factory/squid/commit/257ad12e3007cbf789a1f83bd75424bd920760e4#r34033833


thumbX: If you can improve the wiki, do not wait for others.

Original Context:
http://lists.squid-cache.org/pipermail/squid-users/2019-September/021089.html


thumbX: Rule of thumb: Make everything work, including SslBump, _before_
applying custom filtering rules.

Original Context:
http://lists.squid-cache.org/pipermail/squid-users/2019-August/020877.html


thumbX: One Must() or assert() per ANDed condition. For example, instead of writing `assert(a && b)`, write `assert(a); assert(b)`.

Original Context:
https://github.com/squid-cache/squid/pull/139#discussion_r167452838
https://github.com/squid-cache/squid/pull/411#discussion_r301246356


thumbX: If you can use `auto`, use `auto`. Get into the habit of typing `auto` first and changing it to a specific type later if needed.

Original Context: https://github.com/squid-cache/squid/pull/425#discussion_r299032627


thumbX: If you can use `const`, use `const`. Get into the habit of typing
`const` first and removing it later if needed.

Exception: Omit useless `const` in declaration of by-value parameters (e.g.,
do not say `void f(const int x);`), especially since some compilers may warn
about it. The same `const` is useful in the corresponding definitions (e.g.,
do write `void f(const int x) {...}`).

Original Context: https://github.com/squid-cache/squid/pull/425#discussion_r299032627


thumbX: Do not catch exceptions that you do not intend to (at least partially) handle. Let them just bubble up. The "handling" itself is very catcher-specific, of course.

Original Context: https://github.com/squid-cache/squid/pull/411#discussion_r290083328


thumbX: A pull request (i.e. the future official commit) should include all
the essentials for understanding the change, including a PR description (i.e.
future commit message) that is usable without consulting external sources.

Original Context:
https://github.com/squid-cache/squid/pull/410#issuecomment-496346607


thumbX: In source code comments, avoid repeating what the code already clearly
says.

This is one of the applications of the even more general [DRY] principle.

[DRY]:
    https://en.wikipedia.org/wiki/Don%27t_repeat_yourself
    "Don't repeat yourself"

Original Context: Occurred many times in many contexts but added here as a
generalization of thumbW(In source code comments,...)


thumbX: Small, single-`#if CONDITION` preprocessor statements should not add the `/* CONDITION */` comment to the closing `#endif`. Do not document what the code already clearly says.

Original Context:
https://github.com/measurement-factory/squid/pull/20#discussion_r277031498


thumbX: The code using a macro in such a way that it can be compiled when the
macro is not `#defined` must explicitly (i.e. directly) `#include` the header
providing that macro. Relying on _indirect_ inclusion is too risky because the
list of indirectly included headers may be changed by those who do not know
about this hidden dependency.

The `squid.h` header provides ./configure-driven feature-test macros (e.g.,
`USE_OPENSSL` or `HAVE_GSSAPI`) that any source code file can count on.

Original Context:
https://github.com/squid-cache/squid/pull/369#discussion_r259392784


thumbX: `foo.h` should `#include` (directly or indirectly) all headers that
are necessary for compiling `foo.h`. Squid headers should not explicitly
`#include` `squid.h` but other Squid sources must explicitly `#include`
`squid.h` as the very first `#include`.

Original Context: Inspired by thumbW(The code using a macro...).


thumbX: A function must not put garbage into its output parameter regardless
of what that function returns. If the returned value tells the caller that the
output parameter is not meaningful, then either reset the parameter (if the
callers naturally require that) or leave the output parameter as-is (by
default).

The above suggestions work especially well when the code also follows the
ES.20 ["initialize all variables"] rule from the C++ Core Guidelines.

[initialize all variables]:
  https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Res-always

Original Context:
https://github.com/squid-cache/squid/pull/150#issuecomment-365828835


thumbX: In a performance-sensitive setup, the startup=n value for a given
helper should correspond to the maximum number of those helpers actually used
when handling normal day-to-day traffic. While starting as many helpers as are
necessary during a DoS attack may be an overkill, waiting for the load to
increase before starting a reasonable number of helpers is counter-productive
because leads to excessive transaction response times when the load naturally
goes up.

Original Context: http://lists.squid-cache.org/pipermail/squid-users/2018-April/018071.html


thumbX: When referencing a commit ID from a Squid commit message or
documentation:

1. Avoid references to commits outside of the official Squid repository. If
   such references are necessary, augment them with the repository
   information.
2. If referring to a non-master commit in the official Squid repository, the
   reference should be augmented with the official branch name (for human
   convenience -- git itself does not care).
3. If referring to a master commit in the official Squid repository, the
   reference may be augmented with the "master" branch name. Omitting
   augmentation reduces noise, but adding it may be a good idea in some cases
   (e.g., where multiple commits from multiple branches are mentioned in the
   same context).

When working on feature branches, it is a good idea to augment any feature
branch commit reference with "this branch" or a similar marker that is easy to
spot and remove such references later if they sneak into PR code or
description. Authors should keep in mind that feature branch references are
volatile because the often-required rebasing and/or squashing invalidates
them. (Official branches are never rebased or squashed, of course.)

Original Context:
https://github.com/squid-cache/squid/pull/187#issuecomment-387092785


thumbX: If you do not need to change a line, do not change it just to polish
it (e.g., to remove HERE or replace NULLs).

If you polished a line because it needed to be changed but then those changes
were reverted, revert the polishing as well -- internal code gyrations do not
matter.

See also: thumbW(If you have to change a...)

Original Context:
http://bugs.squid-cache.org/show_bug.cgi?id=4857#c7


thumbX: If you have to change a source code line for some PR-related reason,
then do apply basic cleanup changes as well (e.g., HERE removal and NULL
replacement).

This rule does not apply to automated source code changes, of course. Scripts
may polish what they change if it is easy to do so, but it is unreasonable to
expect every source code formatting or modernizing script to make every
polishing touch a human would apply.

See also: thumbW(If you do not need to change a line...)


Original Context:
http://bugs.squid-cache.org/show_bug.cgi?id=4857#c7




thumbX: If Squid can generate the right blocking message, use Squid (instead
of the eCAP or ICAP service) to generate the right blocking message.

This rule can be derived from the general "do not reinvent the wheel" rule or
even the [DRY] rule. If Squid can do something well, let it do it.

Original Context:
http://lists.squid-cache.org/pipermail/squid-users/2018-June/018374.html


thumbX: Function definitions, including templated function definitions in
header files should use the `inline` keyword.

This rule can be derived from the SF.2 ["headers may not contain non-inline
function definitions"] rule from the C++ Core Guidelines.

[headers may not contain non-inline function definitions]:
  https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Rs-inline

Original Context:
https://github.com/measurement-factory/squid/pull/14#discussion_r218995374




thumbX: Do not label a PR `M-cleared-for-merge` until no more human PR work is
anticipated.

Clearing the PR too early may result in premature PR merges when another human
is manipulating the PR state. For example, a new positive review of an
already-cleared PR may be enough to merge the PR before the same reviewer has
enough time to request a review from another person. Anubis actions were
carefully written to avoid similar accidents when the bot manipulates the PR,
but we cannot control human actions in a similar way.

The `M-cleared-for-merge` label is not meant to be used as a "PR blocking"
mechanism. It is essentially an "Anubis blocking" mechanism that provides a
human-driven check that the PR is indeed ready to go in as far as human work
is concerned.

Original Context:
https://github.com/squid-cache/squid/pull/287#issuecomment-424370852





thumbX: Selecting the right cache_dir type:
1. Keep it as simple as possible (but no simpler): If you are OK without SMP
   and with ufs cache_dirs, then use no SMP and ufs.
2. If you have to use SMP (i.e. multiple workers), then use rock cache_dir.
3. Otherwise, use whatever cache_dir type works best for you (ufs, rock, aufs,
   or diskd), but keep in mind that ufs is simpler than others, and that
   nobody actively works on aufs and diskd variants right now.


Original Context:
http://bugs.squid-cache.org/show_bug.cgi?id=4886#c6



thumbX: Do not say `Foo::` inside `Foo`.

This is one of the applications of the even more general [DRY] or "avoid code
duplication" principle.

Original Context:
https://github.com/squid-cache/squid/pull/310#discussion_r228557709




thumbX: When selecting the Squid (or OS) version to deploy: Start with the
latest supported version you can deploy.

This rule maximizes the remaining support period, giving your more time before
the required upgrade.

Original Context:
http://lists.squid-cache.org/pipermail/squid-users/2018-October/019572.html


thumbX: When selecting a Squid deployment operating system: If you are already
familiar with a particular OS, go with that OS.

Squid operates well-enough on many modern OSes (excluding Windows), for many
common applications. This rule flattens the learning curve.

Original Context:
http://lists.squid-cache.org/pipermail/squid-users/2018-October/019572.html



thumbX: Squid does not officially support any OpenSSL derivatives such as
BoringSSL or LibreSSL, but if you, at your own risk, want to switch among
those libraries, then install _each_ library in a library-specific location
that is not known to any other package or library. Do not install any of them
in the "standard" locations like `/usr/local/lib/` or `/usr/local/include/`
that may be used by other packages or libraries.


Original Context:
http://bugs.squid-cache.org/show_bug.cgi?id=4662#c12



thumbX: If an existing `forward.h` file is missing a forward declaration,
please fix that file (instead of forward-declaring elsewhere).

Adding a new `forward.h` file to an existing `src` subdirectory is also a good
idea (assuming your pull request requires declarations provided by the library
in that directory). Unfortunately, dealing with forward declarations in `src`
files is more challenging -- we want to move those files away from `src`
rather than gobble all their forward declarations in `src/forward.h`.

Original Context:
http://lists.squid-cache.org/pipermail/squid-dev/2017-January/007811.html


thumbX: New squid.conf directives should look like this:

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


thumbX: Fewer refresh_pattern lines lead to better performance.

For example, replacing

```
refresh_pattern a 720 100% 4320
refresh_pattern b 720 100% 4320
```

with

```
refresh_pattern (a|b) 720 100% 4320
```

May improve refresh_pattern application speed (at the expense of less readable
configuration).


Original Context:
http://lists.squid-cache.org/pipermail/squid-users/2017-February/014502.html


thumbX: If list elements have to store their position in their list (for any
reason), then a performance-sensitive code should use an intrusive list.

This rule might be useful when selecting the best type for a container, but it
is probably too specific to its original context to be generally useful.
TODO: Remove?

Original Context:
http://lists.squid-cache.org/pipermail/squid-dev/2017-April/008473.html


thumbX: When writing ssl_bump rules, always tell Squid what to do at every
step by making sure that at least one applicable ssl_bump rule matches at
every step.


Original Context:
http://lists.squid-cache.org/pipermail/squid-users/2017-June/015698.html


thumbX: When there is an alternative, avoid regular expressions.

Regular expressions are relatively slow and may be difficult to interpret correctly. If you can easily fulfill your requirements with a directive that uses exact string matching (or an equivalent matching without any regular expressions), then go with that directive.

On the other hand, avoid replacing one simple regular expression with 1000 exact string matches, of course.

See also: thumbW(Fewer refresh_pattern lines...)

Original Context:
http://lists.squid-cache.org/pipermail/squid-users/2017-September/016453.html


thumbX: If you are splicing a domain, then never bump it. If you want to bump
it, then neither splice it nor allow any other ways to reach it except through
the bumping proxy.

It is technically possible to transition a domain from being spliced/relayed
to bumped, but it can be a painful process involving a lot of unavoidable TLS
related "errors" for clients during the transition timeout dictated by the
HSTS header and/or similar things.

Original Context:
http://lists.squid-cache.org/pipermail/squid-users/2017-November/016883.html


thumbX: Put boolean data members last.

This rule often reduces padding and might help enable some low-level compiler
optimizations. The rule is not meant for classes that have only a few
concurrent instances where other design concerns probably outweigh padding.

Original Context:
http://lists.squid-cache.org/pipermail/squid-dev/2016-January/004680.html


thumbX: All `src/` header files should be included using paths relative to `src`.

When already in `src/foo/`, writing `#include "f.h"` to include `src/foo/f.h`
is tempting and will, sometimes, work. However, to improve code search-ability
and maintainability as well as to reduce unintended header clashes, use
`#include "foo/f.h"`.

Squid guarantees header name uniqueness only when that name has a proper path.

For header files located in the `src/` directory itself, do not use any path:
`#include "g.h"`.

Original Context: A private review.


thumbX: If you want to optimize performance of a disk-caching Squid running on
beefy hardware, and are ready to spend non-trivial amounts of time/labor/money
doing that, then consider the following rules:

1. Use the largest cache_mem your system can handle safely. Please note that,
   without [shared_memory_locking], Squid will not tell you when you
   over-allocate but may crash.

[shared_memory_locking]:
  http://www.squid-cache.org/Doc/config/shared_memory_locking/
  "make sure the requested cache_mem bytes are available at startup"

2. One or two CPU core reserved for the OS, depending on network usage levels.
   Use OS CPU affinity configuration to restrict network interrupts to these
   OS core(s).

3. One Rock cache_dir per physical disk spindle with no other cache_dirs. No
   RAID. Diskers may be able to use virtual CPU cores. Tuning Rock is tricky.
   See Performance Tuning recommendations at
   http://wiki.squid-cache.org/Features/RockStore

4. One SMP worker per remaining non-virtual CPU cores.

5. Use [cpu_affinity_map] to set CPU affinity for each Squid worker and disker
   process. Prohibit kernel from moving other processes onto CPU cores
   reserved for those processes.

[cpu_affinity_map]:
  http://www.squid-cache.org/Doc/config/cpu_affinity_map/
  "assigns Squid kids to CPU cores"

6. Watch individual CPU core utilization (not just the total!). Adjust the
   number of workers, the number of diskers, and CPU affinity
   maps/restrictions to achieve balance while leaving a healthy overload
   safety margin.

Squid is unlikely to work well in a demanding environment without investment
of labor and/or money (i.e., others' labor). In some environments, Squid code
changes are needed. Squid is a complex product with many features and
problems. If you want top-notch performance, there is no simple blueprint.
Getting Squid work well in a challenging environment is not a "one weekend"
project. Unfortunately.

Original Context:
http://lists.squid-cache.org/pipermail/squid-users/2016-February/009248.html


thumbX: When solving reverse proxy caching problems, it is best to fix them
using proper HTTP mechanisms rather than proxy config workarounds.

Using HTTP mechanisms allows all other proxies (and possibly clients) that use
your reverse proxy to benefit from your fixes.

Original Context:
http://lists.squid-cache.org/pipermail/squid-users/2016-April/010236.html


thumbX: When suspecting a Squid bug, check whether an upgrade resolves the
issue.

This is especially good advice for actively changing areas such as (at the
time of writing) SslBump.

Original Context:
http://lists.squid-cache.org/pipermail/squid-users/2016-April/010266.html


thumbX: To decide whether to adapt an HTTP message using Squid configuration
or an adaptation service, consider the following rules:

1. Message body mangling belongs to eCAP/ICAP.

2. If header mangling decisions require information contained in the message
   body, such mangling belongs to eCAP/ICAP.

3. Header field mangling that cannot be expressed using "add field", "delete
   field", or "a regex substitution of the field value" operation belongs to
   eCAP/ICAP.

4. All other mangling actions can be supported directly in squid.conf, at any
   vectoring point.

Original Context:
http://lists.squid-cache.org/pipermail/squid-dev/2016-June/005970.html


thumbX: Library-agnostic APIs (e.g., `Security`) must be the same, regardless
of the library Squid is being compiled with.

The implementation of those Library-agnostic APIs may depend on the library,
of course. For example, it is also perfectly fine for GnuTLS-specific code to
use types that are different from types used by OpenSSL-specific code.
However, the library-agnostic APIs must remain the same.

For example, adding or relying on something like this is a bad idea:

```C++
namespace Security {
#if USE_OPENSSL
    typedef LockingPointer<...> SessionPointer;
#elif USE_GNUTLS
    typedef TidyPointer<...> SessionPointer;
#endif
};
```

... unless LockingPointer and TidyPointer have the same API.

Violating this rule leads to library-agnostic code that compiles and works
fine with one library but either does not compile or, worse, does not work
with the other library.


Original Context:
http://lists.squid-cache.org/pipermail/squid-dev/2016-June/006015.html


thumbX: When running SMP Squid or multiple Squid instances that share
underlying hardware:

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


thumbX: When testing, check that the changed code was actually exercised.
Avoid claiming that the PR was tested unless you have verified that the
changes were exercised during the tests.

Original Context:
http://lists.squid-cache.org/pipermail/squid-dev/2016-October/007131.html


thumbX: Make everything work, including SslBump, _before_ customizing
http_access rules.

"Everything else" is hard enough to get right on its own, even without all the
common problems related to http_access customizations.

Original Context:
http://lists.squid-cache.org/pipermail/squid-users/2019-August/020877.html
