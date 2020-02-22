If you can use `const`, use `const`.
----

Get into the habit of typing `const` first and removing it later if needed.

Exception: Omit useless `const` in declaration of by-value parameters (e.g.,
do not say `void f(const int x);`), especially since some compilers may warn
about it. The same `const` is useful in the corresponding definitions (e.g.,
do write `void f(const int x) {...}`).

Original Context: https://github.com/squid-cache/squid/pull/425#discussion_r299032627
