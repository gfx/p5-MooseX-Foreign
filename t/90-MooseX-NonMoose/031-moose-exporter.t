#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 8;

BEGIN {
    require Moose;
    require Moose::Util::MetaRole;

    package Foo::Exporter::Class;
    use Moose::Exporter;
    Moose::Exporter->setup_import_methods(also => ['Moose']);

    sub init_meta {
        shift;
        my %options = @_;
        Moose->init_meta(%options);
        return Moose::Util::MetaRole::apply_metaclass_roles(
            for_class               => $options{for_class},
            metaclass_roles         => ['MooseX::Foreign::Meta::Role::Class'],
        );
    }

    package Foo::Exporter::ClassAndConstructor;
    use Moose::Exporter;
    Moose::Exporter->setup_import_methods(also => ['Moose']);

    sub init_meta {
        shift;
        my %options = @_;
        Moose->init_meta(%options);
        return Moose::Util::MetaRole::apply_metaclass_roles(
            for_class               => $options{for_class},
            metaclass_roles         => ['MooseX::Foreign::Meta::Role::Class'],
            constructor_class_roles =>
                ['MooseX::Foreign::Meta::Role::Method::Constructor'],
        );
    }

}

package Foo;

sub new { bless {}, shift }

package Foo::Moose;
BEGIN { Foo::Exporter::Class->import }
extends 'Foo';

package Foo::Moose2;
BEGIN { Foo::Exporter::ClassAndConstructor->import }
extends 'Foo';

package main;
ok(Foo::Moose->meta->has_method('new'),
   'using only the metaclass trait still installs the constructor');
isa_ok(Foo::Moose->new, 'Moose::Object');
isa_ok(Foo::Moose->new, 'Foo');
my $method = Foo::Moose->meta->get_method('new');
Foo::Moose->meta->make_immutable;
{ local $TODO = "method objects has a different semantics from Moose's";
is(Foo::Moose->meta->get_method('new'), $method,
   'inlining doesn\'t happen when the constructor trait isn\'t used');
}
ok(Foo::Moose2->meta->has_method('new'),
   'using only the metaclass trait still installs the constructor');
isa_ok(Foo::Moose2->new, 'Moose::Object');
isa_ok(Foo::Moose2->new, 'Foo');
my $method2 = Foo::Moose2->meta->get_method('new');
Foo::Moose2->meta->make_immutable;
isnt(Foo::Moose2->meta->get_method('new'), $method2,
   'inlining does happen when the constructor trait is used');
