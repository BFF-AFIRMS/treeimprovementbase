<!-- Mason Templating -->
{@html `<!--
<%init>
my $bodyVar = "var set in html body";
my $scriptVar = "hello from the server";
my $user_role = '';
if ($c->user) {
    $user_role = $c->user->get_object()->get_user_type();
}
</%init>
-->`}

<hr class="mt-4 mb-8">

bodyVar: {@html `<% $bodyVar %>`}
<br/>
scriptVar:  {@html `<% $scriptVar %>`}
<br/>

{@html `
% if ( $user_role eq 'curator' ) {
    You are a curator
% } else {
    You are not a curator
% }
`}
