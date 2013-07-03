# NAME

Time::Profiler provides scope-automatic or manual code time measurement. 

# SYNOPSIS

    #!/usr/bin/perl
    use strict;
    use Time::Profiler;

    my $pr = new Time::Profiler; # create new profiler instance

    print "begin main\n";
    # begin main:: scope measuring with automatic names
    my $_ps = $pr->begin_scope(); 

    t1();
    t2();
    sleep( 2 );

    # main:: scope will not end before reporting so must be stopped manually
    $_ps->stop(); 

    # print profiler stats
    print $pr->report(); 

    sub t1
    {   
      print "begin t1\n";
      # begin t1 function scope time measuring
      my $_ps = $pr->begin_scope();

      t2();
      sleep( 3 );
      t2();
      # t1 function scope ends here so timing will end automatically
    }

    sub t2
    {
      print "begin t2\n";
      # begin t2 function scope time measuring
      my $_ps = $pr->begin_scope();

      sleep( 1 );
      # t2 function scope ends here so timing will end automatically
    }

# DESCRIPTION

Time::Profiler is designed to be called inside scopes (or functions) which
are needed to be measured. It provides automatic, manual or cumulative
scope names.

# OUTPUT

The example in the SYNOPSIS will print this output:

    begin main
    begin t1
    begin t2
    begin t2
    begin t2

    SINGLE PROFILE SCOPES
        1 time  =      8.001 sec. main::
        1 time  =      5.000 sec. main::t1
        3 times =      3.000 sec. main::t2

    TREE PROFILE SCOPES
        1 time  =      8.001 sec. main::
        1 time  =      5.000 sec. |    main::t1
        2 times =      2.000 sec. |    |    main::t2
        1 time  =      1.000 sec. |    main::t2

# AUTOMATIC SCOPE NAMES

Time::Profiler will traverse the stack and will construct automatic name if
scope name is left empty or '\*':

    t1();
    t2();

    print $pr->report();

    sub t1
    {
      my $_ps = $pr->begin_scope(); # same as below
      t2();
      sleep( 3 );
    }

    sub t2
    {
      my $_ps = $pr->begin_scope( '*' ); # same as above
      sleep( 2 );
    }

Output will be:

    SINGLE PROFILE SCOPES
        1 time  =      5.000 sec. main::t1
        2 times =      4.000 sec. main::t2

    TREE PROFILE SCOPES
                                  main::
        1 time  =      5.000 sec. |    main::t1
        1 time  =      2.000 sec. |    |    main::t2
        1 time  =      2.000 sec. |    main::t2

# MANUAL SCOPE NAMES

Manual names can force fixed scope names:

    my $_ps = $pr->begin_scope( 'ROOT' );

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
      my $_ps = $pr->begin_scope( 'ROOT/T1/T2' );
      sleep( 2 );
    }

This will force main:: scope name to be 'ROOT' and only nested t2() name 
'ROOT/T1/T2'. Output will be:

    SINGLE PROFILE SCOPES
        1 time  =      5.000 sec. ROOT
        1 time  =      2.000 sec. T2

    TREE PROFILE SCOPES
        1 time  =      5.000 sec. ROOT
                                  |    T1
        1 time  =      2.000 sec. |    |    T2

So t1() has no profile stats but t2() scope name (path) is measured inside
the 'ROOT' scope.

# CUMULATIVE SCOPE NAMES

Cumulative names begin with '+' and allow measurement aggregation for same 
type functions. For example database module may have read\_data() and 
write\_data() function, which read or write data from/to different tables:

    sub read_data
    {
      my $table_name = shift;
      my $_ps = $pr->begin_scope( "+DB/READ_DATA/$table_name" );
      ...
    }

    sub write_data
    {
      my $table_name = shift;
      my $_ps = $pr->begin_scope( "+DB/WRITE_DATA/$table_name" );
      ...
    }

Possible output:

    SINGLE PROFILE SCOPES
        1 time  =     14.000 sec. DB
        1 time  =      8.000 sec. DB/READ_DATA
        1 time  =      6.000 sec. DB/WRITE_DATA
        2 time  =      4.000 sec. DB/READ_DATA/CLIENTS
        2 time  =      4.000 sec. DB/READ_DATA/ADDRESSES
        1 time  =      3.000 sec. DB/WRITE_DATA/CLIENTS
        1 time  =      3.000 sec. DB/WRITE_DATA/ADDRESSES



This will measure several things:

- all calls to read\_data() and write\_data() regardless $table\_name (DB)
- all calls to read\_data() regardless $table\_name (DB/READ\_DATA)
- all calls to write\_data() regardless $table\_name (DB/WRITE\_DATA)
- all calls to read\_data() for specific $table\_name (DB/READ\_DATA/$table\_name)
- all calls to write\_data() for specific $table\_name (DB/WRITE\_DATA/$table\_name)

This is almost complete set of possible measurements. The only missing case is
measuring of all DB access for specific table (DB/\*/$table\_name). To achieve this
MIXED names must be used (see below):

    sub read_data
    {
      my $table_name = shift;
      my $_ps = $pr->begin_scope( "+DB/READ_DATA/$table_name", "+DB_$table_name" );
      ...
    }

Possible output:

    SINGLE PROFILE SCOPES
        1 time  =     14.000 sec. DB
        1 time  =      8.000 sec. DB/READ_DATA
        3 time  =      7.000 sec. DB_CLIENTS
        3 time  =      7.000 sec. DB_ADDRESSES
        1 time  =      6.000 sec. DB/WRITE_DATA
        2 time  =      4.000 sec. DB/READ_DATA/CLIENTS
        2 time  =      4.000 sec. DB/READ_DATA/ADDRESSES
        1 time  =      3.000 sec. DB/WRITE_DATA/CLIENTS
        1 time  =      3.000 sec. DB/WRITE_DATA/ADDRESSES

# MIXED NAMES

Scopes may have multiple names including mixed types names:

    sub read_data
    {
      my $table_name = shift;
      my $_ps = $pr->begin_scope( "*", "+TT/T2", "ALL_FUNCS" );
      ...
    }

This will produce automatic scope name ("\*"), 
cumulative ("+DB/READ\_DATA/$table\_name") and 
manual static one ("ALL\_FUNCS").

In this case stats will be mixed in the same profiler output:

    SINGLE PROFILE SCOPES
        1 time  =      5.000 sec. ROOT
        1 time  =      2.000 sec. main::t2
        1 time  =      2.000 sec. TT/
        1 time  =      2.000 sec. ALL_FUNCS
        1 time  =      2.000 sec. TT/T2/

    TREE PROFILE SCOPES
        1 time  =      5.000 sec. ROOT
        1 time  =      2.000 sec. TT
        1 time  =      2.000 sec. |    T2
        1 time  =      2.000 sec. ALL_FUNCS
                                  main::
                                  |    main::t1
        1 time  =      2.000 sec. |    |    main::t2

# PITFALLS

Avoid cumulative names for recursive or nested functions, otherwise some stats 
may seem wrong:

    t1();
    t2();

    print $pr->report();

    sub t1
    {
      my $_ps = $pr->begin_scope( '+ALL_FUNCS/T1' );
      

      t2();
      sleep( 3 );
    }

    sub t2
    {
      my $_ps = $pr->begin_scope( '+ALL_FUNCS/T2' );
      sleep( 2 );
    }

Output will be:

    SINGLE PROFILE SCOPES
        3 times =      9.000 sec. ALL_FUNCS/
        1 time  =      5.000 sec. ALL_FUNCS/T1/
        2 times =      4.000 sec. ALL_FUNCS/T2/

    TREE PROFILE SCOPES
        3 times =      9.000 sec. ALL_FUNCS
        1 time  =      5.000 sec. |    T1
        2 times =      4.000 sec. |    T2

Total program execution time is actually 7 sec. but we see that ALL\_FUNCS says
9 sec. This is because t2() time is measured twice: once as separate function
call and second time as nested function.

# GITHUB REPOSITORY

    https://github.com/cade-vs/perl-time-profiler
    

    git clone git://github.com/cade-vs/perl-time-profiler.git

# AUTHOR

    Vladi Belperchinov-Shabanski "Cade"

    <cade@biscom.net> <cade@datamax.bg> <cade@cpan.org>

    http://cade.datamax.bg
