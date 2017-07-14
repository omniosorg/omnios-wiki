#! /usr/bin/perl

$args = join(' ', @ARGV);

# uncomment to set size of s0 on install disk (in format syntax)
$rpool_size = '5gb';

# uncomment to add additional options for zpool create
$rpool_opts = '-O compression=lz4';

# uncomment to set swap size
#$swap_size = '512m';

# uncomment to set dump size
#$dump_size = '256m';

open(LOG, '>>/tmp/omnios_zpool_install.log');

print LOG "$0 $args\n";
if ($0 =~ /zpool$/) {
	if ($args =~ /^create.* (\S+)/) {
		$device = $1;
		if ($rpool_size) {
			$device =~ s/s0$//;
			open(FH, '>/tmp/format.script');
			print FH "p\n0\n\n\n\n$rpool_size\nlabel\nq\nq\n";
			close(FH);
			system("format -d $device -f /tmp/format.script > /tmp/format.out 2>&1");
		}
		if ($rpool_opts) {
			$args =~ s/create -f/create -f $rpool_opts/;
		}
		system("umount /usr/sbin/zpool");
	}
	print LOG "/tmp/zpool $args\n";
	system("/tmp/zpool $args");
	exit($? >> 8);
}
elsif ($0 =~ /zfs$/) {
	if ($args =~ /^create/) {
		if ($swap_size && $args =~ /swap$/) {
			$args =~ s/-V .* rpool/-V $swap_size rpool/;
		}
		if ($args =~ /dump$/) {
			if ($dump_size) {
				$args =~ s/-V .* rpool/-V $dump_size rpool/;
			}
			system("umount /usr/sbin/zfs");
		}
	}
	print LOG "/tmp/zfs $args\n";
	system("/tmp/zfs $args");
	exit($? >> 8);
}
else {
	system("cp /usr/sbin/zpool /tmp; cp /usr/sbin/zfs /tmp");
	system("mount -F lofs $0 /usr/sbin/zpool");
	system("mount -F lofs $0 /usr/sbin/zfs");
}
