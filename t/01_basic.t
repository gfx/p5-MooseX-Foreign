#!perl -w

use strict;
use Test::More;
use Test::Exception;

use Test::Moose;

my $person_destroyed = 0;
my $myperson_built   = 0;
BEGIN{
    package Person;
    use Class::Struct;

    struct Person => {
        name => '$',
        age  => '$',
    };

    sub DESTROY { $person_destroyed++ }
}

{
    package MyPerson;
    use Moose;
    use MooseX::Foreign qw(Person);

    has handle_name => (
        is => 'rw',
        isa => 'Str',
    );

    sub BUILD { $myperson_built++ }
}

does_ok(MyPerson->meta, 'MooseX::Foreign::Meta::Role::Class');

does_ok(MyPerson->meta->constructor_class,
    'MooseX::Foreign::Meta::Role::Method::Constructor');
does_ok(MyPerson->meta->destructor_class,
    'MooseX::Foreign::Meta::Role::Method::Destructor');

with_immutable {
    my $p = MyPerson->new(name => 'Goro Fuji', age => 27, handle_name => 'gfx');

    isa_ok $p, 'MyPerson';
    isa_ok $p, 'Person';
    isa_ok $p, 'Moose::Object';

    is $p->name,        'Goro Fuji', 'from the base class';
    is $p->age,          27,         'from the base class';
    is $p->handle_name, 'gfx',       'from the derived class';

} qw(MyPerson);

is $person_destroyed, 2, "the base class's destructor is called";
is $myperson_built,   2, 'BUILD is called';

done_testing;
