#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 4;

package Foo;

sub new {
    my $class = shift;
    bless { name => $_[0] }, $class;
}

sub name { shift->{name} }

package Foo::Moose;
use Moose;
use MooseX::Foreign;
extends 'Foo';

has foo => (
    is => 'rw',
);

sub BUILDARGS {
    my $class = shift;
    # remove the argument that's only for passing to the superclass constructor
    shift;
    return $class->SUPER::BUILDARGS(@_);
}

package main;

my $foo = Foo::Moose->new('bar', foo => 'baz');
is($foo->name, 'bar', 'superclass constructor gets the right args');
is($foo->foo,  'baz', 'subclass constructor gets the right args');
Foo::Moose->meta->make_immutable;
$foo = Foo::Moose->new('bar', foo => 'baz');
is($foo->name, 'bar', 'superclass constructor gets the right args (immutable)');
is($foo->foo,  'baz', 'subclass constructor gets the right args (immutable)');
