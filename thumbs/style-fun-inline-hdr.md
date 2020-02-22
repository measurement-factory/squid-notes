Function definitions in header files should use the `inline` keyword.
----

This rule covers templated function definitions and specializations.

This rule can be derived from the SF.2 ["headers may not contain non-inline
function definitions"] rule from the C++ Core Guidelines.

[headers may not contain non-inline function definitions]:
  https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Rs-inline

Original Context:
https://github.com/measurement-factory/squid/pull/14#discussion_r218995374
