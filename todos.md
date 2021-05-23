# Straightforward to-do items for developers

This page is dedicated to useful development tasks that can be accomplished in
a few work hours or days while avoiding complicated design or implementation
matters. Achieving high-quality, valuable results should be easier with these
curated tasks. As any documentation, this list may contain stale items, so do
not hesitate to double check on [squid-dev].

[squid-dev]:
  http://www.squid-cache.org/Support/mailing-lists.html#squid-dev
  "Squid Developers Mailing List"

* Address the following TODO, preferably in v5.
```C++
// TODO: Deprecate this style to avoid this dangerous guessing.
if (Log::TheConfig.knownFormat(token)) {
```


* Address the following TODO, noting the plural in "checks":
```C++
// TODO: Switch Ipc::RequestId::Index to uint64_t and drop these 0 checks.
if (++LastIndex == 0) // don't use zero value as an ID
    ++LastIndex;
```


* Address the following TODO, using `git grep timercmp` to find candidates:
```C++
// TODO: Remove direct timercmp() calls in legacy code.
```


* Address the following TODO:
```C++
// TODO: Remove change-reducing "&" before the official commit.
const auto reply = &mem().freshestReply();
```


* Address the following TODOs:
```C++
assert(imslen < 0); // TODO: Either remove imslen or support it properly.
```
```C++
// TODO: consider removing currently unsupported imslen parameter
bool modifiedSince(const time_t ims, const int imslen = -1) const;
```


* Address the following TODO by using the suggested alternative math in the
  second `if` to remove the FPE check (i.e. the first `if`). Double check and
  then assert() that `b` (i.e. `expectlen`) is indeed always positive.
```C++
// XXX: This is absurd! TODO: For positives, "a/(b/c) > d" is "a*c > b*d".
if (expectlen < 100) {
   debugs(90, 3, "quick-abort? NO avoid FPE");
   return false;
}

if ((curlen / (expectlen / 100)) > (Config.quickAbort.pct)) {
   debugs(90, 3, "quick-abort? NO past point of no return");
   return false;
}
```


* Address the following TODO:
```C++
//TODO: remove, it is unconditionally defined and always used.
#define PEER_MULTICAST_SIBLINGS 1
```


* Address the "use" part of the following TODO, moving the forward declaration
  into base/forward.h. Also add any other missing forward declarations of
  public src/base/*h classes.
```C++
class Packable; // TODO: Add and use base/forward.h.
```


* Address the following TODO by adding any using Raw::upto(n) which will limit
  the size value of passed to PrintHex() and write() inside Raw::print(). That
  value is currently size_.
```C++
if (name_len > 65534) {
    /* String must be LESS THAN 64K and it adds a terminating NULL */
    // TODO: update this to show proper name_len in Raw markup, but not print all that
    debugs(55, 2, "ignoring huge header field (" << Raw("field_start", field_start, 100) << "...)");
```


* Address the following TODO:
```C++
/* TODO: Remove this change-minimizing hack */
using Io = Store::IoStatus;
static constexpr Io ioUndecided = Store::ioUndecided;
static constexpr Io ioReading = Store::ioReading;
static constexpr Io ioWriting = Store::ioWriting;
static constexpr Io ioDone = Store::ioDone;
```


* Address the following TODO (yes, we should). Print CurrentException. See `git
  grep -2 debugs.*CurrentException` for inspiration.
```C++
} catch (const std::exception &x) { // TODO: should we catch ... as well?
    debugs(20, 2, "mem-caching error writing entry " << e << ": " << x.what());
```


* Address the following TODO by reporting the caught exception using
  CurrentException (in addition to status()). See `git grep -2
  debugs.*CurrentException` for inspiration. Also remove `HERE`.
```C++
} catch (...) { // TODO: be more specific
    debugs(33, 3, HERE << "malformed chunks" << bodyPipe->status());
```


* Address the following TODO:
```C++
// TODO: Drop deprecated style #1 support. We already warn about it, and
// its exceptional treatment makes detecting "module" typos impractical!
cl->parseOptions(LegacyParser, "squid");
```


* Remove legacy `ctx_` debugging made obsolete by CodeContext, probably by
  porting existing Measurement Factory [commit 944cb4c] to the current master
  branch.

[commit 944cb4c]:
  https://github.com/measurement-factory/squid/commit/944cb4c4152db4a97c8e0ec995ea89efb757f785
  "Removed legacy context-based debugging in favor of CodeContext"

The following high-value to-dos are more complex. Each requires posting an RFC
to [squid-dev] to check consensus and, if that succeeds, checking with
[squid-users] to gather (lack of known) usage information:

* After checking for actual use on Squid mailing lists, remove Gopher support
  if there is consensus that the feature is not used enough to warrant
  support. The feature implementation is of law quality, and it is a source of
  vulnerabilities.

* After checking for actual use on Squid mailing lists, remove WHOIS support
  if there is consensus that the feature is not used enough to warrant
  support. The feature implementation is of law quality, and it is a source of
  vulnerabilities.

* After checking for actual use on Squid mailing lists, remove URN support if
  there is consensus that the feature is not used enough to warrant support.
  The feature implementation is of law quality, and it is a source of
  vulnerabilities.

* After checking for actual use on Squid mailing lists, remove ESI support if
  there is consensus that the feature is not used enough to warrant support.
  The feature implementation is of law quality. The code uses legacy APIs that
  are in the way of other code refactoring. It is a persistent source of
  vulnerabilities.

* After checking for actual use on Squid mailing lists, remove HTTP pipelining
  support if there is consensus that the feature is not used enough to warrant
  support. The feature is often forgotten/neglected in code refactoring,
  significantly complicates development (when its needs are not forgotten), is
  probably always buggy, and is a source of vulnerabilities.

[squid-users]:
  http://www.squid-cache.org/Support/mailing-lists.html#squid-users
  "Squid Users Mailing List"


----

The Squid Project has seen a trickle of requests for a to-do list like this
throughout the years, but a [specific GitHub exchange] was the last drop that
prompted its creation.


[specific GitHub exchange]:
  https://github.com/squid-cache/squid/pull/828#issuecomment-846451733
  "Squid Project PR 828 comments that triggered this list creation"
