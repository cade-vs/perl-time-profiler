##############################################################################
#
#  Time::Profile::Scope
#  Vladi Belperchinov-Shabanski "Cade" <cade@biscom.net> <cade@datamax.bg>
#
#  This is internal module, see Time::Profile for external API
#
#  DISTRIBUTED UNDER GPLv2
#
##############################################################################
package Time::Profile::Scope;
use strict;
use Time::HR;
use Carp;

##############################################################################

sub new
{
  my $class    = shift;
  my $profiler = shift;
  my $key      = shift;
  
  carp( "second argument is expected to be Time::Profiler" ) unless ref( $profiler ) eq 'Time::Profile';
  carp( "scope timer key required" ) unless $key;
  
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
  
  $dt /= 1_000_000_000; # report in seconds
  
  my $pr = $self->__pr()->__data();
  
  my $key = $self->{ 'KEY' };

  $pr->{ "$key:COUNT" }++;
  $pr->{ "$key:TIME"  } += $dt;
  
  delete $self->{ 'START' };
}

sub DESTROY
{
  my $self = shift;

print "SCOPE DESTROY\n";
  
  $self->stop() if $self->{ 'START' };
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
