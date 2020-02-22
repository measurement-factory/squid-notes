Squid does not officially support any OpenSSL derivatives such as BoringSSL
or LibreSSL, but if you, at your own risk, want to switch among those
libraries, then install _each_ library in a library-specific location that is
not known to any other package or library.
----

Do not install any of those libraries in the "standard" locations like
`/usr/local/lib/` or `/usr/local/include/` that may be used by other packages
or libraries.

Original Context:
http://bugs.squid-cache.org/show_bug.cgi?id=4662#c12
