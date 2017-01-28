package Pod::ProjectDocs::Parser::XHTML;

use strict;
use warnings;

use base qw(Pod::Simple::XHTML);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);

    return $self;
}

sub start_head1 {
   my($self, $attrs) = @_;

   $self->{_in_head1} = 1;

   return $self->SUPER::start_head1($attrs);
}

sub end_head1 {
   my($self, $attrs) = @_;

   delete $self->{_in_head1};

   return $self->SUPER::end_head1($attrs);
}

sub handle_text {
   my($self, $text) = @_;

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
