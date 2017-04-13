package Pod::ProjectDocs::Parser;

use strict;
use warnings;

# VERSION

use Pod::ProjectDocs::Parser::XHTML;
use Pod::ProjectDocs::Template;

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub local_modules {
    my ($self, $modules) = @_;

    if (defined $modules) {
        $self->{_local_modules} = $modules;
    }

    return $self->{_local_modules};
}

sub gen_html {
    my($self, %args) = @_;

    my $doc        = $args{doc};
    my $components = $args{components};
    my $mgr_desc   = $args{desc};

    my $parser = Pod::ProjectDocs::Parser::XHTML->new();

    # Use HTML5 with UTF8.
    $parser->html_doctype('<!DOCTYPE html>');
    $parser->html_charset('UTF-8');
    $parser->html_encode_chars(q{&<>'"});

    # Add our custom CSS file.
    $parser->html_header_tags($parser->html_header_tags() . "\n" . $components->{css}->tag($doc));

    # Generator options.
    $parser->index(1);
    $parser->title($doc->name() . ' &mdash; ' . $doc->config()->title());
    $parser->anchor_items(1);
    $parser->no_errata_section(1);

    # Custom options.
    $parser->doc($doc);
    $parser->local_modules($self->local_modules());
    $parser->current_files_output_path( $doc->get_output_path );

    # Close <div class="pod"> (injected below) and add "generated by" content.
    $parser->html_footer('</div><div class="footer">generated by <a href="http://search.cpan.org/perldoc?Pod::ProjectDocs">Pod::ProjectDocs</a></div></body></html>');

    # Start parsing/generation.
    my $output;
    $parser->output_string(\$output);
    $parser->parse_file($doc->origin);

    # Add body header section and open <div class="pod">.
    my $header_box = $self->_generate_header_box($doc, $mgr_desc);
    $output =~ s/<body[^>]*>\K/$header_box\n<div class="pod">/;

    return $output;
}

sub _generate_header_box {
    my($self, $doc, $mgr_desc) = @_;
    my $tt = Pod::ProjectDocs::Template->new;
    my $text = $tt->process($doc, $doc->data, {
        title    => $doc->config->title,
        desc     => $doc->config->desc,
        name     => $doc->name,
        outroot  => $doc->config->outroot,
        src      => $doc->get_output_src_path,
        mgr_desc => $mgr_desc,
    });
    return $text if $^O ne 'MSWin32';

    while ( $text =~ s|href="(.*?)\\(.*?)"|href="$1/$2"| ) {
        next;
    }
    return $text;
}


1;
