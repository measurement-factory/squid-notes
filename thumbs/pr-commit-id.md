When referencing a commit ID from a Squid commit message or documentation:
----

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
