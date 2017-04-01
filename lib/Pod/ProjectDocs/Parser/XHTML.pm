package Pod::ProjectDocs::Parser::XHTML;

use strict;
use warnings;

use base qw(Pod::Simple::XHTML);

use File::Basename();
use File::Spec();
use HTML::Entities(); # Required for proper entity detection in Pod::Simple::XHTML.

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    return $self;
}

sub local_modules {
    my ($self, $modules) = @_;

    if (defined $modules) {
        $self->{_local_modules} = $modules;
    }

    return $self->{_local_modules};
}

sub current_files_output_path {
    my ($self, $path) = @_;

    if (defined $path) {
        $self->{_current_files_output_path} = $path;
    }

    return $self->{_current_files_output_path};
}

sub resolve_pod_page_link {
    my ( $self, $module, $section ) = @_;

    my %module_map = %{$self->local_modules() // {}};

    if ($module && $module_map{$module}) {
        $section = defined $section ? '#' . $self->idify( $section, 1 ) : '';
        return $self->_resolve_rel_path($module_map{$module}) . $section;
    }

    return $self->SUPER::resolve_pod_page_link($module, $section);

}

sub _resolve_rel_path {
    my ($self, $path ) = @_;
    my $curpath = $self->current_files_output_path;
    my ($name, $dir) = File::Basename::fileparse $curpath, qr/\.html/;
    return File::Spec->abs2rel($path, $dir);
}

1;
