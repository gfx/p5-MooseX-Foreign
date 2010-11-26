#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 4;

package Foo;

sub new { bless {}, shift }

package Foo::Moose;
use Moose -traits => 'MooseX::Foreign::Meta::Role::Class';
extends 'Foo';

package main;
ok(Foo::Moose->meta->has_method('new'),
   'using only the metaclass trait still installs the constructor');
isa_ok(Foo::Moose->new, 'Moose::Object');
isa_ok(Foo::Moose->new, 'Foo');
my $method = Foo::Moose->meta->get_method('new');
Foo::Moose->meta->make_immutable;
{ local $TODO = "method object semantics is different from Moose's";
is(Foo::Moose->meta->get_method('new'), $method,
   'inlining doesn\'t happen when the constructor trait isn\'t used');
}
