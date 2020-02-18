# Review principles

The following principles are based on well-known peer review practices such as
those published by [Google]. They have been adjusted to better accommodate
Squid Project specifics.

[Google]:
  https://google.github.io/eng-practices/review/reviewer/standard.html
  "Google's Standard of Code Review"

<a name="rp1"></a>rp1: Most pull requests that improve Squid should be cleaned
up and accepted
----

This primary principle reflects several key facts:

1. We want to accept _all_ Squid improvements, but
2. most PRs require a cleanup before they can be accepted, and
3. some exceptional PRs should be rejected even if they improve Squid.

The first statement expresses the fundamentally open nature of the Squid
Project: All kinds of improvements from all kinds of contributors are welcomed
by default. Squid is not a "highly opinionated" but a "highly configurable"
tool. PR rejection is a rare exception that must be carefully substantiated by
the rejecting reviewer.

The second statement implies that a PR should not be immediately rejected just
because it needs to be polished. Nobody expects perfect PRs. If necessary,
reviewers use GitHub change requests to direct cleanup. See the
[Cleanup](#cleanup) section below for more details.

If the Project wants to accept all improvements, why reject some of them?
Accepting any pull request has its costs -- even the best PRs usually add new
code that will need to be maintained long-term and require short-term spending
on review, testing, change log adjustments, backporting, etc. Both the PR
author and the reviewer must carefully assess PR's positive and negative
sides, considering not just the code being modified but the entire Squid
codebase as well as Squid maintenance, deployment, interoperability, and legal
concerns.

In most cases, apples-to-oranges comparisons make it impossible to formally
prove that the positives outweigh the negatives, necessitating judgment calls
during high-level PR review. It may be difficult for potential contributors to
predict the outcome of such a review. Authors that plan to submit a large or
controversial PRs are encouraged to post a Request For Comments email to the
squid-dev mailing list _before_ diving into development. While an RFC
acceptance does not guarantee future PR acceptance, most unrectifiable PR
rejections can be avoided during an RFC review.

<a name="rp2"></a>rp2: On matters of style, the [Style Guide] is the authority
----

Styling not covered by the Guide (or covered by the currently conflicting
Guide requirements) is a matter of personal preference. Personal choices
should still be consistent with the committed code, especially with similar
committed code (but [rp4](#rp4) caveats often apply here as well). In gray area
styling cases, the author’s style should be accepted.

[Style Guide]:
  https://wiki.squid-cache.org/SquidCodingGuidelines
  "contains, among other things, code styling requirements"

Ideally, accepted code should need no auto-reformatting, and official
auto-formatting can be considered to be an implicit part of the Style Guide,
defining nearly all formatting aspects. However, insisting on that ideal is
premature until Squid auto-formatting tools become more comprehensive and
developer-friendly.

<a name="rp3"></a>rp3: Quality software is designed on solid engineering
principles
----

Pull requests should be weighed on those principles, regardless of personal
preferences. While there are usually many ways to make the code "work" in a
given environment, non-trivial development tasks often have very few correct
design- or architecture-level solutions. If the author can demonstrate (based
on solid engineering principles) that several approaches are equally valid,
then the reviewer should accept the solution preferred by the author.
Otherwise, the choice is dictated by the well-known principles of software
engineering.


<a name="rp4"></a>rp4: If no other rule applies, then the reviewer may ask the
author to be consistent with what is in the current codebase
----

Unfortunately, finding consistency in Squid code or, more importantly,
agreeing which code should be considered in that search is often difficult.
For example, when 30 old code snippets use approach X while 3 newer commits
use approach Y, it may be difficult to agree whether the PR should follow X or
Y.

In the scope of this "last resort" principle, newer contributors should avoid
insisting on "their way" if more experienced Squid developers agree on what
"consistent" means in the scope of a particular PR change. Unfortunately,
experienced Squid developers often themselves disagree on that definition.


<a name="rp5"></a>rp5: Reviewers should initiate new and update old reviews in
the right order
----

The order itself is detailed in the "Pull request review order" section
further below.

This rule ensures steady Squid development progress even though following the
correct order may delay new code submissions (by that reviewer) and/or delay
the initial review of newly submitted pull requests. The Squid Project
optimizes for the speed at which its virtual team of developers, as a whole,
can move Squid forward, as opposed to optimizing for the speed at which any
individual developer can commit code. The speed of individual development is
important; it’s just not as important as the velocity of the entire team.

Slow reviews are well-known to reduce overall project velocity, cause
developer protests/exodus, and even decrease the overall quality of the
codebase by discouraging code cleanups, refactorings, and further improvements
to existing pull requests. While the Squid Project does not have enough
resources to consistently provide same-day or even same-week reviews, we can
assure steady non-discriminatory Project-wide progress.


<a name="rp6"></a>rp6: Reviewers should follow well-known general code review
practices
----

See, for example, [How to write code review comments].

[How to write code review comments]:
  https://google.github.io/eng-practices/review/reviewer/comments.html

<a name="rp7"></a>rp7: Authors should follow well-known general code submission
practices
----

See, for example, [Author’s guide to getting through code review].

[Author’s guide to getting through code review]:
  https://google.github.io/eng-practices/review/developer/


<a name="cleanup"></a>Pull request cleanup
====

Most PRs can be improved, but endless PR improvements block Project progress,
and some PR improvements are prohibitively expensive. Balancing the desire for
clean code with the need to move forward at reasonable cost requires judgment
calls by authors and reviewers alike. These judgment calls often lead to
costly arguments. This section offers a classification of cleanup cases in
hope to structure and narrow those arguments, but it starts with a cleanup
justification because many new contributors are surprised by requests to
change already "working" PR code.

## Why cleanup _now_?

It is tempting to accept any PR that is free of known functionality bugs:
Things can always be polished later! Way before the GitHub days, the Squid
Project had used a similar approach for many years. The current hodgepodge of
architectural styles, API generations, and unmaintainable (but "working" or
"used to be working") legacy code is, in part, attributed to that practice.

Squid lacks an army of developers that can quickly clean up dirty PRs, but
even the behemoths with more than enough resources still [require cleanup]
before most pull requests go in. Cleanup may delay pull request merging,
especially if the primary author is unwilling or unable to improve their work,
but the alternative is even worse: Letting developers "clean things up later"
results in codebase degeneration.

[require cleanup]:
  https://github.com/google/eng-practices/blob/master/review/reviewer/pushback.md#cleaning-it-up-later-later
  "Google's 'Cleaning It Up Later' discussion"

Good developers usually tolerate (and some really crazy ones even appreciate!)
easy cleanup suggestions. Good reviewers usually do not insist on difficult
changes going way beyond PR scope. Review troubles thrive in the large gray
area between those two extremes.

The table below partially illustrates the cleanup decision space by
highlighting two key dimensions: the importance of the problem versus the
difficulty of implementing a solution. The two `?` cells require judgment
calls. The other data cells represent the Squid Project PR cleanup policy.

|            | easy | moderate | hard |
|:----------:|:----:|:--------:|:----:|
|**critical**|  fix |    fix   |  fix |
|**serious** |  fix |    fix   |   ?  |
|**minor**   |  fix |     ?    | TODO |

Problem severity is classified based on the expected problem impact, including
that impact probability:

* **critical**: May cause (or significantly increase the probability of)
  crashes, protocol violations, frequent timeouts, sensitive information
  leaks, code bugs that are difficult for an average human reviewer and
  deployed CI tools to detect, code maintenance nightmares, etc.

  Examples may include
  * breaking known-to-be-used Squid functionality
  * duplicating large amounts of code
  * using linear search for a potentially large data collection

* **serious**: Lies somewhere between _critical_ and _minor_.

  Examples may include
  * responding with an "unsupported" error to valid but somewhat unusual
    messages in a new/experimental protocol
  * adding an extra disk I/Os due to careless offset alignment (in
    miss-storing code that buffers I/Os)
  * sprinkling code with 20 difficult-to-connect `int` variables used for the
    same distinct purpose (instead of introducing a `FooBar` typedef)
  * violating [C++ Core Guidelines] (in non-critical ways)
  * forgetting to document a new method that has a dangerous unexpected side
    effect

[C++ Core Guidelines]:
  https://github.com/isocpp/CppCoreGuidelines/blob/master/CppCoreGuidelines.md

* **minor**: Introduces (or adds to) a non-critical annoyance that may, under
  rare conditions, slightly inconvenience users or developers.

  Examples may include
  * using identical error texts for different error messages
  * forgetting to use `const` or `auto`
  * adding a C++ comment that describes what the code already clearly says
  * using unusual for Squid code formatting (without violating Squid Style
    Guide)

Cleanup difficulty categories are based on the cleanup cost, expressed in time
a capable developer is likely to spend on addressing the problem:

* **easy**: Can be addressed by a capable developer in **under an hour**.

  In many (but not all) cases, easy cleanup changes
  * would be unwelcomed as a stand-alone PR (e.g., because their partial
    nature would not properly address a widespread legacy problem (e.g.,
    fixing spelling of comments added by the being-reviewed PR would not fix
    numerous spelling errors in other comments) and/or because the expenses
    associated with such a stand-alone PR would outweigh its benefits) (XXX:
    too long/complex!);
  * can be reviewed in isolation (i.e., without requiring a re-review of the
    entire PR);
  * do not increase the risks associated with the PR; and
  * either belong to the PR scope or can be classified as scope-neutral
    cleanup of the already modified/moved/added code.

  Examples may include
  * spelling fixes for newly added text
  * improving new variable names using specific suggestions
  * removing essentially unused code (either introduced by the PR or made
    unused by PR changes)
  * naming a general-purpose type (e.g., `int`) repeatedly used in new methods
    for the same purpose
  * fixing const-correctness of new or touched old declarations
  * avoiding legacy APIs using readily-available replacements
  * making code exception safe\(r\) using readily-available smart pointers
  * adding a C++ comment to document an out-of-scope bug that was discovered
    during review

* **moderate**: Lies somewhere between _easy_ and _hard_.

  Examples may include
  * non-trivial encapsulation of repeated code logic in a new function or
    small class (e.g., a new smart pointer with a well-understood logic that
    was not needed in before-PR code)
  * modernizing parsing using readily-available tokenizers
  * modernizing error handling using C++ exceptions

* **hard**: Is likely to take a capable developer significantly **more than a
  few hours**.

  In many (but not all) cases, hard cleanup
  * enlarges/changes PR scope;
  * is likely to be accepted as a stand-alone PR;
  * or noticeably increases PR risks.

  Examples may include
  * replacing 100 sequential `if` statements and offset increments with an
    incremental parser for a new protocol/language
  * adding SMP support to a state-rich legacy feature.

Cleanup action:

* **fix**: The PR should be changed, using reviewer suggestions as guidance
  and adjusting them as needed. See the "Who should clean up?" section below
  for a related discussion.

* **TODO**: If the author prefers not to implement the changes (that both
  reviewer and author agree fall under this TODO action), the author can just
  add a TODO comment instead.

* `?`: Reviewer and author should try to agree on whether to fix the problem
  or add a TODO comment. If no agreement is in sight after a few iterations, a
  real-time conversation may work better than continuing exchanging GitHub
  comments.


## Who should clean up?

Most cleanup changes should be done by the PR author. There are two notable
exceptions:

* _Uncontroversial_ changes that are easier for the reviewer to apply than to
  request: If the author has allowed PR branch modification (allow-PR-changes
  is a GitHub default that can be overwritten by the author when opening a new
  PR), then the reviewer should apply such changes instead of requesting them.
  This approach saves everybody time. Reviewers ought to be conservative when
  classifying changes as uncontroversial; most of such changes fall into the
  "easy" category (but many "easy" fixes, especially those for critical and
  serious problems are not like that). It is always best to make one change
  per commit. Authors are responsible for verifying all (and have the absolute
  right to reverse any) reviewer changes, of course -- the PR branch belongs
  to the author.

* Changes that the author does not disagree with (in principle) but does not
  have enough time or desire to enact. The PR remains blocked, waiting for
  another developer to implement the requested changes. A reviewer may be that
  developer, but they do not have to volunteer to apply such changes or commit
  to a specific delivery timeline. The author (not the reviewer) is ultimately
  responsible for advancing the PR at this stage (e.g., by finding somebody
  else who can apply the requested changes). The Squid Project does not
  currently have a policy for closing PRs that wait for a long time, but such
  a timeout policy may be introduced retroactively.

To preserve author's ability to restore their branch to the author-desired
state, reviewers shall not force-push into PR branches (unless each push is
sanctioned by the author). Fortunately, there is usually no need to force-push
because the Squid Project currently automatically rebases and squashes all PR
branch commits while merging those changes; adding a few housekeeping or even
buggy commits is not a problem.

Authors should minimize force-pushing during review because it confuses GitHub
and might interfere with the pending reviewer fixes. Again, there is usually
no need to force-push because the Squid Project currently automatically
rebases and squashes all PR branch commits while merging those changes.


<a name="order"></a>Pull request review order
====

A reviewer should prioritize (re)reviewing pull requests already awaiting his
or her review (`review-requested:@me`). Among those pull requests, the
reviewer should process the PR corresponding to the first matching condition
below (the rule links show matching PRs in the Squid code repository):

1. the oldest pull request labeled `review-1` --
   [`label:review-1 review-requested:@me sort:created-asc`](https://github.com/squid-cache/squid/pulls?q=label%3Areview-1+review-requested%3A%40me+sort%3Acreated-asc)
1. the oldest pull request labeled `review-2` --
   [`label:review-2 review-requested:@me sort:created-asc`](https://github.com/squid-cache/squid/pulls?q=label%3Areview-2+review-requested%3A%40me+sort%3Acreated-asc)
1. the oldest pull request labeled `review-3` --
   [`label:review-3 review-requested:@me sort:created-asc`](https://github.com/squid-cache/squid/pulls?q=label%3Areview-3+review-requested%3A%40me+sort%3Acreated-asc)
1. the oldest pull request --
   [`review-requested:@me sort:created-asc`](https://github.com/squid-cache/squid/pulls?q=review-requested%3A%40me+sort%3Acreated-asc)

Once the reviewer submits their review or comment, they should select the next
candidate using the same procedure. Note that the set of awaiting pull
requests and/or PR labels may change during the review.

When no pull requests await the reviewer, he or she should process the oldest
pull request of interest to them (if any) -- [`is:open sort:created-asc`](https://github.com/squid-cache/squid/pulls?q=is%3Aopen+sort%3Acreated-asc).

Reviewer R who wants to stop a PR from being merged until they review it
should self-request a review of that PR using GitHub's "request PR review"
feature. The PR will then wait for the reviewer, sooner or later bubbling up
to the top of the reviewer list.

Reviewers that also author code should prioritize advancing previously
reviewed PRs over other development work. Ideally, the set of PRs they can
review should be empty before they switch into development mode. The opposite
bias would make it trivial for a given reviewer to stop or skew Squid
development progress, especially if others continue to diligently advance PRs
submitted by that reviewer. Please note that since there is no requirement to
start new reviews, the maximum number of previously reviewed PRs that need
advancing is fully controlled by the reviewer. A person who wants to do more
development than review should balance their commitments accordingly.

Most reviews, especially follow-ups, should not take more than a few hours (if
they do, then something probably went wrong; a quick clarification and/or a
real-time discussion may be a lot more productive than a huge comprehensive
review in those special cases). If the reviewer knows that they do not have
enough time to review a higher-priority PR but can review a much smaller one,
then the reviewer may _occasionally_ violate the prescribed review order as
long as they advance higher-priority PRs within a week or two.

If higher-priority PRs are neglected for many weeks (especially while the
reviewer submits new reviews or PRs), then the reviewer should adjust her
schedule to prevent further violations or end her involvement in neglected PRs
(i.e. remove requests for her reviews and dismiss her blocking reviews). This
rule is necessary to ensure steady, unbiased Squid progress and adherence to
basic reviewer code of ethics/conduct.

The experimental `review-*` labels are meant to direct other reviewers
attention to what the labeler considers the most important PRs right now
(using any importance criteria). Only core developers may assign `review-*`
labels. Only the person who added the `review-*` label to a given PR can
remove that label from that PR. At any given time, there can be at most three
`review-*` labels assigned by the same person to PRs within a repository.
Thus, a core reviewer can label up to three PRs (optionally giving each
labeled PR a different review priority). Naturally, `review-*` labels will get
stale -- the labeler usually cannot reassign the label immediately after the
review ends. That is OK -- it is trivial for a reviewer to skip labeled PRs
that are no longer waiting for that reviewer.

When all reviews happen on a reasonable schedule, these experimental PR labels
are not be needed at all!


# See also

For a collection of curated references related to code reviews see, for
example, [elsewhere](https://github.com/joho/awesome-code-review).
