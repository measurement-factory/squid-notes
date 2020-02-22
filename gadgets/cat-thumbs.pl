#!/usr/bin/perl -w

# Concatenates Rule of Thumb files, with some minor preprocessing.

use strict;
use warnings;
use IO::File;

# thumb_ref{adapt-where}
sub thumbRef {
    my ($id) = @_;
    return sprintf('[#%s](#%s)', $id, $id);
}

# http://lists.squid-cache.org/pipermail/squid-users/2018-October/019572.html
sub mlistRef {
    my ($root, $list, $email) = @_;
    my $url = "$root/$list/$email";
    my ($id) = ($email =~ /(\d+).html$/);
    die("cannot find email ID in $email; stopped") unless length $id;
    return sprintf('email-[%s](%s)@%s', $id, $url, $list);
}

# http://bugs.squid-cache.org/show_bug.cgi?id=4662#c12
sub bugzillaRef {
    my ($cgi, $id, $comment) = @_;
    my $url = "${cgi}?id=${id}#c$comment";
    return sprintf('bug-%s#[c%s](%s)', $id, $comment, $url);
}

# https://github.com/measurement-factory/squid/pull/20#discussion_r277031498
sub githubRef {
    my ($root, $hash) = @_;
    my $url = "${root}#${hash}";
    my ($id) = ($hash =~ /(\d+)$/);
    die("cannot find GitHub comment ID in $hash; stopped") unless length $id;
    return sprintf('comment-[%s](%s)@github', $id, $url);
}

sub printThumb {
    my ($fname) = @_;
    die() unless length $fname;

    my $in = IO::File->new("< $fname") or die("cannot open $fname: $!; stopped");
    local $/;
    my $thumb = <$in>;

    $thumb =~ s@(?=[^\\])thumb_ref[{](.*?)[}]@&thumbRef($1)@eg;
    $thumb =~ s@(?=[^(])(\Qhttp://lists.squid-cache.org/pipermail\E)/(squid-\w+)/(.*?[.]html)@&mlistRef($1, $2, $3)@eg;
    $thumb =~ s@(?=[^(])(\Qhttp://bugs.squid-cache.org/show_bug.cgi\E)[?]id=(\d+)#c(\d+)@&bugzillaRef($1, $2, $3)@eg;
    $thumb =~ s@(?=[^(])(\Qhttps://github.com/\E.*)#([\w_-]+)@&githubRef($1, $2)@eg;

    my ($thumbName) = ($fname =~ m@([^/]+)[.]md$@);
    die("cannot guess thumb name in $fname; stopped") unless length $thumbName;
    printf('<a name="%s"></a>', $thumbName);
    print($thumb);
    print("\n");
    printf('Rule of thumb ID: <a href="#%s">#%s</a>', $thumbName, $thumbName);
    print("\n\n");
    print("----");
    print("\n\n");
}

foreach my $thumbFname (@ARGV) {
    &printThumb($thumbFname);
}

exit 0;
