package SGN::Controller::AJAX::Authenticate::Caddy;

use strict;
use Moose;
use JSON;

BEGIN { extends 'Catalyst::Controller::REST' }

__PACKAGE__->config(
    default   => 'application/json',
    stash_key => 'rest',
    map       => { 'application/json' => 'JSON' },
   );

sub authenticate_caddy  : Path('/authenticate/caddy') {
    my $self = shift;
    my $c = shift;

	my $domain_name = $c->config->{main_production_site_domain};
	my $redirect_url = $c->req->param("redirect_url");
	my $server_host = $c->config->{main_production_site_url};

	if ($c->user()) {
		$c->stash->{rest} = { message => "Authorized", status => 200 };
		$c->response->status(200);
	} else {
		$c->stash->{rest} = { message => "Unauthorized", status => 301 };
		$c->response->status(301);
		# Redirect to authentication page, on success, continue to redirect_url
		if ($redirect_url){
			$redirect_url = "$server_host/user/login?goto_url=$redirect_url";
			$c->res->redirect( $redirect_url );
		}
	};
}