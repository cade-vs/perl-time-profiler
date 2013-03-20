##############################################################################
#
#  Time::Profiler
#  Vladi Belperchinov-Shabanski "Cade" <cade@biscom.net> <cade@datamax.bg>
#
#  DISTRIBUTED UNDER GPLv2
#
##############################################################################
package Time::Profiler;
use Time::HR;
use Time::Profiler::Scope;
use Data::Dumper;
use strict;

our $VERSION = '1.00';

##############################################################################

sub new
{
  my $class = shift;
  $class = ref( $class ) || $class;
  my $self = {
               'PROFILER_DATA' => {},
             };
  bless $self, $class;
  return $self;
}

sub begin_scope
{
  my $self = shift;
  my $key  = shift;
  
  my $scope = new Time::Profiler::Scope( $self, $key );
  $scope->start();
  
  return $scope;
}

sub report
{
  my $self = shift;

  my $hr = $self->{ 'PROFILER_DATA' };
  
  return Dumper( $hr );
}

### INTERNAL #################################################################

sub __add_dt
{
  my $self = shift;
  my $key  = shift;
  my $dt   = shift;
  
  my @key = split /\//, $key;
  my $hr = $self->{ 'PROFILER_DATA' };
  
  while( my $k = shift @key )
    {
    $hr->{ $k } ||= {};
    $hr = $hr->{ $k };
    }
  $hr->{ 'COUNT' }++;
  $hr->{ 'TIME'  } += $dt;
}

##############################################################################
1;
##############################################################################
