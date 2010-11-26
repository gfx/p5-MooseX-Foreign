#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 3;

package Foo;

sub new { bless {}, shift }
sub foo { 'Foo' }
sub bar { 'Foo' }
sub baz { ref(shift) }

package Foo::Moose;
use Moose;
use MooseX::Foreign;
extends 'Foo';

sub bar { 'Foo::Moose' }

package main;

my $foo_moose = Foo::Moose->new;
is($foo_moose->foo, 'Foo', 'Foo::Moose->foo');
is($foo_moose->bar, 'Foo::Moose', 'Foo::Moose->bar');
is($foo_moose->baz, 'Foo::Moose', 'Foo::Moose->baz');
