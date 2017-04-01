package Pod::ProjectDocs::Parser::XHTML;

use strict;
use warnings;

use base qw(Pod::Simple::XHTML);

use File::Basename();
use File::Spec();

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

    my %module_map;
    for my $local_module (@{ $self->local_modules() // []}) {
        $module_map{$local_module->{name}} = $local_module->{path};
    }

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

sub start_head1 {
   my ($self, $attrs) = @_;

   $self->{_in_head1} = 1;

   return $self->SUPER::start_head1($attrs);
}

sub end_head1 {
   my ($self, $attrs) = @_;

   delete $self->{_in_head1};

   return $self->SUPER::end_head1($attrs);
}

sub handle_text {
   my ($self, $text) = @_;

   if ($self->{_titleflag}) {
       $self->_setTitle($text);
       delete $self->{_titleflag};

   }
   elsif ($self->{_in_head1} && $text eq 'NAME') {
       $self->{_titleflag} = 1;
   }
   else {
       delete $self->{_titleflag};
   }

   return $self->SUPER::handle_text($text);
}

sub _setTitle {
    my $self = shift;
    my $paragraph = shift;

    if ($paragraph =~ m/^(.+?) - /) {
        $self->title($1);
    } elsif ($paragraph =~ m/^(.+?): /) {
        $self->title($1);
    } elsif ($paragraph =~ m/^(.+?)\.pm/) {
        $self->title($1);
    } else {
        $self->title(substr($paragraph, 0, 80));
    }
}



1;
