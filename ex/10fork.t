use strict;
use LWP::Simple;
use Parallel::ForkManager;

my @calls=(
    'tim', 'sam'
);

# Max 30 processes for parallel download
my $pm = new Parallel::ForkManager(30);

$pm->run_on_finish(
  sub { my ($pid, $exit_code, $ident) = @_;
    print "** $ident just got out of the pool ".
      "with PID $pid and exit code: $exit_code\n";
  }
);

for my $c ( @calls ) {
    $pm->start and next;
    sub_one($c);
    $pm->finish;

}

$pm->finish; # do the exit in the child process


$pm->wait_all_children;
print "all done\n";


sub sub_one {
    my $name = shift;
    for my $n ( 1 .. 20 ) {
        sleep 1;
        print "$name: $n\n";
    }
}

exit;


my $max_procs = 5;
my @names = qw( Fred Jim Lily Steve Jessica Bob Dave Christine Rico Sara );
# hash to resolve PID's back to child specific information

my $pm = new Parallel::ForkManager($max_procs);

# Setup a callback for when a child finishes up so we can
# get it's exit code
$pm->run_on_finish(
  sub { my ($pid, $exit_code, $ident) = @_;
    print "** $ident just got out of the pool ".
      "with PID $pid and exit code: $exit_code\n";
  }
);

$pm->run_on_start(
  sub { my ($pid,$ident)=@_;
    print "** $ident started, pid: $pid\n";
  }
);

$pm->run_on_wait(
  sub {
    print "** Have to wait for one children ...\n"
  },
  0.1
);

foreach my $child ( 0 .. $#names ) {
  my $pid = $pm->start($names[$child]) and next;

  # This code is the child process
  print "This is $names[$child], Child number $child\n";
  sleep ( 2 * $child );
  print "$names[$child], Child $child is about to get out...\n";
  sleep 1;
  $pm->finish($child); # pass an exit code to finish
}

print "Waiting for Children...\n";
$pm->wait_all_children;
print "Everybody is out of the pool!\n";