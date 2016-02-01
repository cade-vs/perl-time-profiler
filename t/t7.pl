#!/usr/bin/perl
use strict;
use Time::Profiler;

my $pr = new Time::Profiler;

{
my $_ps = $pr->begin_scope( "DB/READ_DATA" );

read_table( 'CLIENTS'   );
read_table( 'CLIENTS'   );
read_table( 'ADDRESSES' );
}

{
my $_ps = $pr->begin_scope( "DB/WRITE_DATA" );

write_table( 'CLIENTS'   );
write_table( 'ADDRESSES' );
write_table( 'ADDRESSES' );
}

print $pr->report();


sub read_table
{
  my $table_name = shift;
  my $_ps = $pr->begin_scope( "DB/READ_DATA/$table_name" );
  sleep( 1 );
}

sub write_table
{
  my $table_name = shift;
  my $_ps = $pr->begin_scope( "DB/WRITE_DATA/$table_name" );
  sleep( 2 );
}
