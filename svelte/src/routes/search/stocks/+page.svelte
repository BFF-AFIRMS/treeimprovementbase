{@html `
<%args>

  $sp_person_autocomplete_uri => '/ajax/people/autocomplete'
  $trait_autocomplete_uri     => '/ajax/stock/trait_autocomplete'
  $onto_autocomplete_uri      => '/ajax/cvterm/autocomplete'
  $trait_db_name              => 'SP'

  $organisms       => undef
  $stock_types     => undef
  $breeding_programs => undef
  $editable_stock_props => undef
</%args>

<%init>
  my $var = 'world';
</%init>
`}

<script lang="ts">
  import * as AlertDialog from "$lib/components/ui/alert-dialog/index.js";
  import { buttonVariants } from "$lib/components/ui/button/index.js";
</script>

<h1>Search Stocks</h1>

<p style="color: blue">Hello {@html `<% $var %>`}</p>

<h2>Alert</h2>

<AlertDialog.Root>
  <AlertDialog.Trigger class={buttonVariants({ variant: "outline" })}>
    Show Dialog
  </AlertDialog.Trigger>
  <AlertDialog.Content>
    <AlertDialog.Header>
      <AlertDialog.Title>Are you absolutely sure?</AlertDialog.Title>
      <AlertDialog.Description>
        This action cannot be undone. This will permanently delete your account
        and remove your data from our servers.
      </AlertDialog.Description>
    </AlertDialog.Header>
    <AlertDialog.Footer>
      <AlertDialog.Cancel>Cancel</AlertDialog.Cancel>
      <AlertDialog.Action>Continue</AlertDialog.Action>
    </AlertDialog.Footer>
  </AlertDialog.Content>
</AlertDialog.Root>