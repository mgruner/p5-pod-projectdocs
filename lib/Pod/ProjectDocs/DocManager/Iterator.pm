package Pod::ProjectDocs::DocManager::Iterator;

use strict;
use warnings;

use base qw/Class::Accessor::Fast/;

__PACKAGE__->mk_accessors(qw/manager index/);

sub new {
    my ($class, @args) = @_;
    my $self = bless {}, $class;
    $self->_init(@args);
    return $self;
}

sub _init {
    my ( $self, $manager ) = @_;
    $self->index(0);
    $self->manager($manager);
    return;
}

sub next_document {
    my $self = shift;
    if ( $self->manager->get_docs_num > $self->index ) {
        my $doc = $self->manager->get_doc_at( $self->index );
        $self->index( $self->index + 1 );
        return $doc;
    }
    else {
        return;
    }
}

sub reset_iterator {
    my $self = shift;
    $self->index(0);
    return;
}

1;
__END__
