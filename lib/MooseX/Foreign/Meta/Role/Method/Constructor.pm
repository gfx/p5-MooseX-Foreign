package MooseX::Foreign::Meta::Role::Method::Constructor;
use Moose::Role;

around _generate_instance => sub {
    my($next, $self, $var, $class_var) = @_;

    my $meta = $self->associated_metaclass;

    # The foreign superlcass must have the new method
    my $foreign_buildargs  = $meta->name->can('FOREIGNBUILDARGS');
    my $foreign_superclass = $meta->find_foreign_superclass
        or confess("Oops: no foreign class for " . $meta->name);

    my $foreign_args = $foreign_buildargs
        ? qq{$class_var->FOREIGNBUILDARGS(\@_)}
        :  q{@_};
    return <<CODE;
        my $var = $class_var->${foreign_superclass}::new($foreign_args);
CODE
};

around _generate_BUILDALL => sub {
    my($next, $self) = @_;
    my $meta               = $self->associated_metaclass;
    my $foreign_superclass = $meta->find_foreign_superclass;
    my $needs_buildall     = !$foreign_superclass->can('BUILDALL');

    if($needs_buildall) {
        return $self->$next();
    }
    else {
        return '';
    }
};

no Moose::Role;
1;
__END__

=head1 NAME

MooseX::Foreign::Meta::Role::Method::Constructor - The MooseX::Foreign meta method constructor role

=head1 DESCRIPTION

This is the meta method constructor role for MooseX::Foreign.

=head1 SEE ALSO

L<MooseX::Foreign>

=cut
