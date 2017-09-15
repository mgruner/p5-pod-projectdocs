package Pod::ProjectDocs::Template;

use strict;
use warnings;

# VERSION

use Moose;

use Template;
use File::Basename;
use File::Spec;

has '_curpath' => (
    is => 'rw',
    isa => 'Str',
    default => '',
);

has '_tt' => (
    is => 'ro',
    isa => 'Object',
    default => sub {
        my $self = shift;
        Template->new( {
            FILTERS => {
                relpath => sub {
                    my $path = shift;
                    my $curpath = $self->_curpath();
                    my($name, $dir) = fileparse $curpath, qr/\.html/;
                    return File::Spec->abs2rel($path, $dir);
                },
                return2br => sub {
                    my $text = shift;
                    $text =~ s!\r\n!<br />!g;
                    $text =~ s!\n!<br />!g;
                    return $text;
                }
            },
        } );
    },
);


sub process {
    my($self, $doc, $data, $output) = @_;
    $self->_curpath( $doc->get_output_path );
    $self->{_tt}->process(\$data, $output, \my $text)
        or $self->_croak($self->{_tt}->error);
    $self->_curpath('');
    return $text;
}

sub _croak {
    my($self, $msg) = @_;
    require Carp;
    Carp::croak($msg);
    return;
}

1;
__END__
