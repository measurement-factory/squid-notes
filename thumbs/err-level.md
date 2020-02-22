When reporting various errors, bugs, and problems:
----

1. Level-0/1 messages should be used for important events affecting the Squid
   instance as a whole (e.g., (suspected) serious Squid bugs,
   misconfigurations, and attacks).
2. Individual transaction failures (that do not qualify as important events in
   item 1) should be reflected in access.log records.
3. Level-0/1 messages that may be logged frequently (e.g., those that may be
   triggered by incoming data) should have a reporting limit. In other words,
   Squid should stop reporting them after a while or, better, rate-limit such
   reports.

This rule reduces chances that admins stop paying attention to important
cache.log messages because the cache.log is dominated by
irrelevant-to-the-admin noise and/or relevant-but-overwhelming info. The rule
also prevents DoS attacks via excessive cache.log logging.

Original Context:
https://github.com/squid-cache/squid/pull/411#discussion_r362064319
https://github.com/squid-cache/squid/pull/411#discussion_r382656921
