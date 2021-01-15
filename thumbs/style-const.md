If you can use `const`, use `const`.
----

Get into the habit of typing `const` first and removing it later if needed.

Exception: Omit useless `const` in function _declarations_ (e.g., do not say
`void f(const int);`), especially since some compilers may warn about them.
The same `const` is useful in the corresponding _definitions_ (e.g., do write
`void f(const int x) {...}`).

This rule of thumb, including its exception, echoes [C++ ToW #109]: Meaningful
`const` in Function Declarations.

[C++ ToW #109]:
  https://abseil.io/tips/109

Original Context:
https://github.com/squid-cache/squid/pull/425#discussion_r299032627
