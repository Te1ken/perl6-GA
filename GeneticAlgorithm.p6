use v6;

my $POP_SIZE = 500;
my $GENES = 32;
my $MRATE = 1/300;
my $CRATE = .90;
my $RRATE = 1-($MRATE+$CRATE);
my $TOURNEYSIZE = 10;

my @population;

sub genPop() {
	@population[$_] = roll($GENES, ^2).list for ^$POP_SIZE;
}

sub cross(@p1, @p2) {
#	say "CROSS";
	my $pivot = roll(1, 0..$GENES)[0];
	my @val := |@p1[0..^$pivot], |@p2[$pivot..^$GENES];
	@val;
}

sub mutate(@p1) {
#	say "MUTATED";
	my @p2 = roll($GENES, ^2).list;
	given rand {
		when * < .5	{ cross(@p1,@p2); }
		default		{ cross(@p2,@p1); }
	}
}

sub replicate(@p1) {
#	say "REPLICATED";
	my @child = @p1;
	@child;
}

sub fitness(@p) {
	[+] @p;
}

sub tourneySelect() {
	my @tourney = roll($TOURNEYSIZE, @population).list;
	my $maxFit = -Inf;
	my @best = @tourney[0];
	for @tourney {
		if fitness($_) > $maxFit {
			@best = $_;
			$maxFit = fitness($_);
		}
	}
	@best[0];
}

sub avgFit() {
	my $avg += fitness($_) for @population;
	$avg /= $POP_SIZE;
	say "Average Fitness: $avg";
}

sub generation($count) {
	say "Starting $count...";
	@population = gather {
		for ^$POP_SIZE {
			given rand {
				when * < $MRATE 			{ take mutate(tourneySelect); }
				when $MRATE <= * && * < $CRATE + $MRATE { take cross(tourneySelect, tourneySelect); }
				default					{ take tourneySelect; }
			}
		}
	}

	avgFit;
	
	given $count {
		when 1 { say @population; }
		default { generation($count - 1); }
	}
}

genPop;
generation(10);
