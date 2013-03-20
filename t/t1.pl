#!/usr/bin/perl
use strict;
use Time::Profile;
use Data::Dumper;

my $pr = new Time::Profile;

print "begin main\n";
my $ps1 = $pr->begin_scope( 'MAIN' );
my $ps2 = $pr->begin_scope();

t1();
sleep( 1 );

$ps1->stop();
$ps2->stop();

print $pr->report();

sub t1
{
  print "begin t1\n";
  
  my $ps1 = $pr->begin_scope( 'MAIN/T1' );
  my $ps2 = $pr->begin_scope();
  
  sleep( 2 );
  t2();
  sleep( 2 );
  t2();
  sleep( 2 );
}

sub t2
{
  print "begin t2\n";

  my $ps1 = $pr->begin_scope( 'MAIN/T1/T2' );
  my $ps2 = $pr->begin_scope();
  
  sleep( 2 );
}
