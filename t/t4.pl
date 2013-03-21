#!/usr/bin/perl
use strict;
use Time::Profiler;

my $pr = new Time::Profiler;

print "begin main\n";
my $_ps = $pr->begin_scope();

t1();
t2();
sleep( 2 );

$_ps->stop();

print $pr->report();

sub t1
{
  print "begin t1\n";
  
  my $_ps = $pr->begin_scope( '+ALL_T_FUNCS/T1' );
  
  t2();
  sleep( 3 );
  t2();
}

sub t2
{
  print "begin t2\n";

  my $_ps = $pr->begin_scope( '+ALL_T_FUNCS/T2' );
  
  sleep( 1 );
}
