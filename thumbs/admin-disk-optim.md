If you want to optimize performance of a disk-caching Squid running on beefy
hardware, and are ready to spend non-trivial amounts of time/labor/money
doing that, then consider the following rules:
----

1. Use the largest cache_mem your system can handle safely. Please note that,
   without [shared_memory_locking], Squid will not tell you when you
   over-allocate but may crash.

[shared_memory_locking]:
  http://www.squid-cache.org/Doc/config/shared_memory_locking/
  "make sure the requested cache_mem bytes are available at startup"

2. One or two CPU core reserved for the OS, depending on network usage levels.
   Use OS CPU affinity configuration to restrict network interrupts to these
   OS core(s).

3. One Rock cache_dir per physical disk spindle with no other cache_dirs. No
   RAID. Diskers may be able to use virtual CPU cores. Tuning Rock is tricky.
   See Performance Tuning recommendations at
   http://wiki.squid-cache.org/Features/RockStore

4. One SMP worker per remaining non-virtual CPU cores.

5. Use [cpu_affinity_map] to set CPU affinity for each Squid worker and disker
   process. Prohibit kernel from moving other processes onto CPU cores
   reserved for those processes.

[cpu_affinity_map]:
  http://www.squid-cache.org/Doc/config/cpu_affinity_map/
  "assigns Squid kids to CPU cores"

6. Watch individual CPU core utilization (not just the total!). Adjust the
   number of workers, the number of diskers, and CPU affinity
   maps/restrictions to achieve balance while leaving a healthy overload
   safety margin.

Squid is unlikely to work well in a demanding environment without investment
of labor and/or money (i.e., others' labor). In some environments, Squid code
changes are needed. Squid is a complex product with many features and
problems. If you want top-notch performance, there is no simple blueprint.
Getting Squid work well in a challenging environment is not a "one weekend"
project. Unfortunately.

Original Context:
http://lists.squid-cache.org/pipermail/squid-users/2016-February/009248.html
