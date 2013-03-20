#!/usr/bin/perl
use Time::Profile;

my $pr = new Time::Profile;

print "begin main\n";
my $ps = $pr->begin_scope( 'MAIN' );

t1();

$ps->stop();

print $pr->report();


sub t1
{
  print "begin t1\n";
  
  my $ps = $pr->begin_scope( 'MAIN/T1' );
  
  sleep( 2 );
  t2();
  sleep( 2 );
}

sub t2
{
  print "begin t2\n";

  my $ps = $pr->begin_scope( 'MAIN/T2' );
  
  sleep( 2 );
}
