Fewer refresh_pattern lines lead to better performance.
----

For example, replacing

```
refresh_pattern a 720 100% 4320
refresh_pattern b 720 100% 4320
```

with

```
refresh_pattern (a|b) 720 100% 4320
```

May improve refresh_pattern application speed (at the expense of a less
readable configuration).

Original Context:
http://lists.squid-cache.org/pipermail/squid-users/2017-February/014502.html
