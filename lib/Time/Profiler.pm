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
               'PROFILER_DATA_SINGLE' => {},
               'PROFILER_DATA_TREE'   => {},
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

  my $hrs = $self->{ 'PROFILER_DATA_SINGLE' };
  my $hrt = $self->{ 'PROFILER_DATA_TREE'   };

  my $text;
  $text .= "\n";
  $text .= "SINGLE PROFILE SCOPES\n";
  $text .= $self->__report_level( $hrs, 0 );
  $text .= "\n";
  $text .= "TREE PROFILE SCOPES\n";
  $text .= $self->__report_level( $hrt, 0 );

  if( $self->{ 'DEBUG'  } )
    {
    $text .= "\n";
    $text .= "RAW TREE PROFILE DATA\n";
    $Data::Dumper::sortkeys = 1;
    $text .= Dumper( $hrt );
    }
  
  return $text;
}

### INTERNAL #################################################################

sub __report_level
{
  my $self  = shift;
  my $hr    = shift;
  my $level = shift;
  
  my @k = grep { ! /^:(TIME|COUNT)/ } keys %$hr;
  @k = sort { $hr->{ $b }->{ ':TIME' } <=> $hr->{ $a }->{ ':TIME' } } @k;

  #return "\n" if @k == 0;
  
  my $text;
  for my $k ( @k )
    {
    my $t = $hr->{ $k }->{ ':TIME'  };
    my $c = $hr->{ $k }->{ ':COUNT' };

    my $ts = $c == 1 ? 'time' : 'times';
    my $rs = sprintf( "%5s %-5s = %10.03f sec. ", $c, $ts, $t );
    $rs = ' ' x length( $rs ) if $c == 0;

    $text .= $rs . ( "|    " x $level ) . $k;
    
    $text .= "\n";  
    $text .= $self->__report_level( $hr->{ $k }, $level + 1 );
    }
  
  return $text;  
}

sub __add_dt
{
  my $self = shift;
  my $key  = shift;
  my $dt   = shift;
  
  my @key = split /\//, $key;
  my $hrs = $self->{ 'PROFILER_DATA_SINGLE' };
  my $hrt = $self->{ 'PROFILER_DATA_TREE'   };
  $hrs->{ $key[-1] }{ ':COUNT' }++;
  $hrs->{ $key[-1] }{ ':TIME'  } += $dt;
  
  while( my $k = shift @key )
    {
    $hrt->{ $k } ||= {};
    $hrt = $hrt->{ $k };
    }
  $hrt->{ ':COUNT' }++;
  $hrt->{ ':TIME'  } += $dt;
}

##############################################################################
1;
##############################################################################
