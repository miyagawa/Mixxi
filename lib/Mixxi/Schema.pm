package Mixxi::Schema;
use strict;
use warnings;
use base qw(DBIx::Class::Schema::Loader);

__PACKAGE__->loader_options(
    debug => 1,
);

1;


