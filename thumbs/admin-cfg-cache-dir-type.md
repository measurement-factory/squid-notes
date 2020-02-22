Selecting the right cache_dir type:
----

1. Keep it as simple as possible (but no simpler): If you are OK without SMP
   and with ufs cache_dirs, then use no SMP and ufs.
2. If you have to use multiple workers, then use rock cache_dir.
3. Otherwise, use whatever cache_dir type works best for you (ufs, rock, aufs,
   or diskd), but keep in mind that ufs is simpler than others, and that
   nobody actively works on aufs and diskd variants right now.

Original Context:
http://bugs.squid-cache.org/show_bug.cgi?id=4886#c6
