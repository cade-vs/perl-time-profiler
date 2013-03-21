##############################################################################
#
#  Time::Profiler::Scope
#  Vladi Belperchinov-Shabanski "Cade" <cade@biscom.net> <cade@datamax.bg>
#
#  This is internal module, see Time::Profiler for external API
#
#  DISTRIBUTED UNDER GPLv2
#
##############################################################################
package Time::Profiler::Scope;
use strict;
use Time::HR;
use Carp;

##############################################################################

sub new
{
  my $class    = shift;
  my $profiler = shift;
  my $key      = shift;
  
  carp( "second argument is expected to be Time::Profiler" ) unless ref( $profiler ) eq 'Time::Profiler';
  
  $class = ref( $class ) || $class;
  my $self = {
               'PROFILER' => $profiler,
               'KEY'      => $key,
             };
  bless $self, $class;
  return $self;
}

sub start
{
  my $self = shift;
  
  $self->{ 'START' } = gethrtime();
}

sub stop
{
  my $self = shift;

  carp( "scope timer is not started, use start() first" ) if $self->{ 'START' } == 0;

  my $dt = gethrtime() - $self->{ 'START' };
  
  $dt = int( $dt / 1_000_000 ); # convert to miliseconds
  $dt /= 1_000; # convert to seconds
  
  my $pr = $self->__pr();
  
  my $key = $self->key();

  $pr->__add_dt( $key, $dt );

  delete $self->{ 'START' };
}

sub DESTROY
{
  my $self = shift;

  $self->stop() if $self->{ 'START' };
}

sub key
{
  my $self = shift;

  return $self->{ 'KEY' } if $self->{ 'KEY' };

  my @key;
  my $i = 0;
  my $se = 1; # skip eval
  while ( my ( $pack, $file, $line, $subname, $hasargs, $wantarray, $evaltext, $is_require, $hints, $bitmask, $hinthash ) = caller($i++) )
    {
    next if $subname =~ /^Time::Profiler::/; # skip self
    next if $subname eq '(eval)' and $se;
    $se = 0;
    push @key, "$subname";
    }

  push @key, 'main::';
    
  my $key = join '/', reverse @key;
  
  return $key;
}

### INTERNAL #################################################################

sub __pr
{
  my $self = shift;
  
  return $self->{ 'PROFILER' }
}

##############################################################################
1;
##############################################################################
