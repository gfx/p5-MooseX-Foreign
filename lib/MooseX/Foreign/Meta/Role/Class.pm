package MooseX::Foreign::Meta::Role::Class;
use warnings FATAL => 'all';
use Moose::Role;
use Moose::Util::MetaRole;

has 'foreign_superclass' => (
    is  => 'rw',
    isa => 'ClassName',
);

sub find_foreign_superclass {
    my($self) = @_;
    foreach my $class($self->linearized_isa) {
        my $meta = Class::MOP::get_metaclass_by_name($class);
        next if !(defined $meta and $meta->can('foreign_superclass'));
        my $fsc = $meta->foreign_superclass;
        return $fsc if defined $fsc;
    }
    return undef;
}

around superclasses => sub {
    my($next, $self, @args) = @_;

    my @isa = $self->$next(@args);
    foreach my $super(@args) {
        next if $super->isa('Moose::Object');
        if( $super->can('new') or $super->can('DESTROY') ) {
            $self->inherit_from_foreign_class($super);
        }
    }
    return @isa;
};

#before verify_superclass => sub {
#    my($self, $super, $super_meta) = @_;
#
#    if(defined($super_meta) && $super_meta->does(__PACKAGE__)) {
#        $self->inherit_from_foreign_class($super);
#    }
#    return;
#};

sub inherit_from_foreign_class { # override
    my($self, $foreign_super) = @_;
    # Carp::carp('### ', $self->name, ' inherit from ', $foreign_super);
    if(defined $self->find_foreign_superclass) {
        $self->throw_error(
            "Multiple inheritance"
            . " from foreign classes ($foreign_super, "
            . $self->find_foreign_superclass
            . ") is forbidden");
    }
    my %traits;
    if($foreign_super->can('new')) {
        $traits{constructor} = ['MooseX::Foreign::Meta::Role::Method::Constructor'];
    }
    if($foreign_super->can('DESTROY')) {
        $traits{destructor}  = ['MooseX::Foreign::Meta::Role::Method::Destructor'];
    }
    if(%traits) {
        $_[0] = $self = Moose::Util::MetaRole::apply_metaroles(
            for             => $self,
            class_metaroles => \%traits,
        );
        $self->foreign_superclass($foreign_super);

        # DON'T CREATE INSTANCES BEFORE CALLING make_immutable()
        $self->add_method(
            new => sub { # provided for compatibility
                my $constructor = $self->constructor_class->new(
                    options      => {},
                    metaclass    => $self,
                    is_inline    => 0,
                    package_name => $self->name,
                    name         => 'new',
                );
                $constructor->execute(@_);
         });
        $self->add_method(
            DESTROY => sub {
                my $destructor = $self->destructor_class->new(
                    options      => {},
                    metaclass    => $self,
                    package_name => $self->name,
                    name         => 'DESTROY',
                );
                return $destructor->execute(@_);
        });
    }
    return;
}

around _immutable_options => sub {
    my($next, $self, @args) = @_;
    my %args = $self->$next(@args);
    $args{replace_constructor}++;
    $args{replace_destructor}++;
    return %args;
};

no Moose::Role;
1;
__END__

=head1 NAME

MooseX::Foreign::Meta::Role::Class - The MooseX::Foreign meta class role

=head1 DESCRIPTION

This is the meta class role for MooseX::Foreign.

=head1 SEE ALSO

L<MooseX::Foreign>

=cut
