package Mixxi::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

Mixxi::Controller::Root - Root Controller for Mixxi

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 default

=cut

sub u : Global {
    my ( $self, $c ) = @_;

    eval {
        my $id = $c->req->args->[0];
        $id = Mixxi::Schema::Url->to_id($id) or die "No decodable ID";

        my $url = $c->model('DBIC::Url')->find($id)
            or die "No object with id=$id";

        $c->res->redirect($url->url);
    };

    if ($@) {
        $c->res->redirect($c->uri_for('/url'));
    }
}

sub id : Global {
    my($self, $c) = @_;
    my $id = $c->req->args->[0];
    if ($id =~ /^\d+$/) {
        $c->res->redirect("http://mixi.jp/show_friend.pl?id=" . $id);
    } else {
        $c->res->redirect($c->uri_for('/url'));
    }
}

sub default : Private {
    my($self, $c) = @_;

    eval {
        my $alias = $c->req->args->[0] or die "No alias";
        my $rs = $c->model('DBIC::Url')->search(alias => $alias);
        $rs->count or die "No url matched $alias";
        my $url = $rs->first;

        if ($c->req->cookie('seen')) {
            $c->res->redirect( $url->url );
        } else {
            $c->res->cookies->{seen} = {
                value   => 1,
                expires => '+3d',
            };
            $c->stash->{url} = $url;
            $c->stash->{template} = 'redirect.tt';
        }
    };

    if ($@) {
        return $c->res->redirect($c->uri_for('/url'));
    }
}

=head2 end

Attempt to render a view, if needed.

=cut 

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Tatsuhiko Miyagawa,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
