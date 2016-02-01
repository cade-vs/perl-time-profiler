#!/usr/bin/perl
use strict;
use Time::Profiler;

my $pr = new Time::Profiler;

my $_ps = $pr->begin_scope( 'ROOT' ); # SINGLE scope

t1();
t2();

$_ps->stop;
print $pr->report();

sub t1
{
  # T1 here
  t2();
  sleep( 3 );
}

sub t2
{
  my $_ps = $pr->begin_scope( 'ROOT/T1/T2' ); # TREE scope
  sleep( 2 );
}
