Do not label a PR `M-cleared-for-merge` until no more human PR work is
anticipated.
----

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
