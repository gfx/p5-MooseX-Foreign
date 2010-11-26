use strict;
use warnings;
use inc::Module::Install;

all_from 'lib/MooseX/Foreign.pm';

requires 'Moose' => 0.77;

test_requires 'Test::More' => 0.88; # done_testing()
test_requires 'Test::Requires';

tests_recursive 't', 't/*';
author_tests 'xt';

auto_set_repository() if -d '.git';

clean_files qw(
    MooseX-Foreign-*
    *.stackdump
    cover_db
    nytprof
    *.out
);

WriteAll(check_nmake => 0);
