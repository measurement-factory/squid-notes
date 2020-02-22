A function must not put garbage into its output parameter regardless of what
that function returns.
----

If the returned value tells the caller that the output parameter is not
meaningful, then the function should either reset the parameter (if the
callers naturally require that) or leave the output parameter as-is (by
default).

The above suggestions work especially well when the code also follows the
ES.20 ["initialize all variables"] rule from the C++ Core Guidelines.

[initialize all variables]:
  https://isocpp.github.io/CppCoreGuidelines/CppCoreGuidelines#Res-always

Original Context:
https://github.com/squid-cache/squid/pull/150#issuecomment-365828835
