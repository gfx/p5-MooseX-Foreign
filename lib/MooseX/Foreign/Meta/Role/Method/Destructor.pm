package MooseX::Foreign::Meta::Role::Method::Destructor;
use Moose::Role;

# ugly hack to inject the foreig superclass's DESTROY
around _compile_code => sub {
    my($next, $self, %args) = @_;

    my $meta               = $self->associated_metaclass;
    my $foreign_superclass = $meta->find_foreign_superclass
        or confess("Oops: no foreign superclass for " . $meta->name);

    # if the foreign superclass has DEMOLISHALL, it will be a Mouse class
    if(!$foreign_superclass->can('DEMOLISHALL')){
        $args{code} =~ s/\} \z/ \$self->${foreign_superclass}::DESTROY() \}/xms;
    }

    return $self->$next(%args);
};

no Moose::Role;
1;
__END__

=head1 NAME

MooseX::Foreign::Meta::Role::Method::Destructor - The MooseX::Foreign meta method destructor role

=head1 VERSION

This document describes MooseX::Foreign version 0.003.

=head1 DESCRIPTION

This is the meta method destructor role for MooseX::Foreign.

=head1 SEE ALSO

L<MooseX::Foreign>

=cut
