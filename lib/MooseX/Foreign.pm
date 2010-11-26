package MooseX::Foreign;
use 5.008_001;
use strict;
use warnings;

our $VERSION = '0.003';

use Moose::Util::MetaRole;
use Carp ();

sub import {
    shift;

    my $caller = caller;
    if(!$caller->can('meta')){
        Carp::croak(
              "$caller does not have the meta method"
            . " (did you use Moose for $caller?)");
    }

    Moose::Util::MetaRole::apply_metaroles(
        for => $caller,
        class_metaroles => {
            class => ['MooseX::Foreign::Meta::Role::Class'],
        },
    );

    $caller->meta->superclasses(@_) if @_;
    return;
}

1;
__END__

=head1 NAME

MooseX::Foreign - Extends non-Moose classes as well as Moose classes

=head1 VERSION

This document describes MooseX::Foreign version 0.003.

=head1 SYNOPSIS

    package MyInt;
    use Moose;
    use MooseX::Foreign qw(Math::BigInt);

    has name => (
        is  => 'ro',
        isa => 'Str',
    );

=head1 DESCRIPTION


MooseX::Foreign provides an ability for Moose classes to extend any classes,
including non-Moose classes, including Moose classes.

 
=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 ACKNOWLEDGEMENT

This is a Moose port of MooseX::NonMoose, although the name is different.

=head1 SEE ALSO

L<Moose>

L<Moose>

L<MooseX::NonMoose>

L<MooseX::Alien>

=head1 AUTHOR

Fuji, Goro (gfx) E<lt>gfuji(at)cpan.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2010, Fuji, Goro (gfx). All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
