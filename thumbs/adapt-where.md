To decide whether to adapt an HTTP message using Squid configuration or an
adaptation service, consider the following rules:
----

1. Message body mangling belongs to eCAP/ICAP.

2. If header mangling decisions require information contained in the message
   body, such mangling belongs to eCAP/ICAP.

3. Header field mangling that cannot be expressed using "add field", "delete
   field", or "a regex substitution of the field value" operation belongs to
   eCAP/ICAP.

4. All other mangling actions can be supported directly in squid.conf, at any
   vectoring point.

See also: thumb_ref{adapt-block-by-squid}.

Original Context:
http://lists.squid-cache.org/pipermail/squid-dev/2016-June/005970.html
