package Pod::ProjectDocs::Config;

use strict;
use warnings;

# VERSION

use Moose;

has 'title' => (
    is => 'ro',
    default => "MyProject's Libraries",
    isa => 'Str',
);

has 'desc' => (
    is => 'ro',
    default => "manuals and libraries",
    isa => 'Str',
);

has 'verbose' => (
    is => 'ro',
    # TODO: boolean
);

has 'index' => (
    is => 'ro',
);

has 'forcegen' => (
    is => 'ro',
);

has 'outroot' => (
    is => 'ro',
    isa => 'Str',
);

has 'libroot' => (
    is => 'ro',
);

has 'lang' => (
    is => 'ro',
    default => 'en',
    isa => 'Str',
);

has 'except' => (
    is => 'ro',
);

1;
__END__
