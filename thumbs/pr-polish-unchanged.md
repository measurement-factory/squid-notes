If you do not need to change a line, do not change it just to polish it
(e.g., to remove HERE or replace NULLs).
----

If you polished a line because it needed to be changed but then those changes
were reverted, revert the polishing as well -- internal code gyrations do not
matter.

See also: thumb_ref{pr-polish-changed}.

Original Context:
http://bugs.squid-cache.org/show_bug.cgi?id=4857#c7
