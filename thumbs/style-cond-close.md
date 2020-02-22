Destruction/closure/etc. is always safe (and is always a no-op if repeated)
-- no checks should be needed in the caller.
----

For example, do not write `if (x.open()) x.close()`; just say `x.close()`.
Similarly, do not write `if (x) delete x`; just say `delete x`.

Original Context: https://github.com/measurement-factory/squid/commit/257ad12e3007cbf789a1f83bd75424bd920760e4#r34033833
