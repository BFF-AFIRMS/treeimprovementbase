<h1>ShadCN Page</h1>


<script lang="ts">
  import { Button } from "$lib/components/ui/button/index.js";
  import * as Accordion from "$lib/components/ui/accordion/index.js";
  import * as AlertDialog from "$lib/components/ui/alert-dialog/index.js";
  import { buttonVariants } from "$lib/components/ui/button/index.js";
</script>

<h1>Welcome to SvelteKit</h1>
<p>Visit <a href="https://svelte.dev/docs/kit">svelte.dev/docs/kit</a> to read the documentation</p>

<h2>Button</h2>
<Button class="text-red-900">Click me</Button>

<h2>Accordion</h2>
<Accordion.Root type="single">
  <Accordion.Item value="item-1">
    <Accordion.Trigger>Is it accessible?</Accordion.Trigger>
    <Accordion.Content>
      Yes. It adheres to the WAI-ARIA design pattern.
    </Accordion.Content>
  </Accordion.Item>
</Accordion.Root>

<h2>Table</h2>
<table class="table-fixed">
  <thead>
    <tr>
      <th>Song</th>
      <th>Artist</th>
      <th>Year</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>The Sliding Mr. Bones (Next Stop, Pottersville)</td>
      <td>Malcolm Lockyer</td>
      <td>1961</td>
    </tr>
    <tr>
      <td>Witchy Woman</td>
      <td>The Eagles</td>
      <td>1972</td>
    </tr>
    <tr>
      <td>Shining Star</td>
      <td>Earth, Wind, and Fire</td>
      <td>1975</td>
    </tr>
  </tbody>
</table>

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

<h2>Routing</h2>

<ul>
  <li><a href="/about">About my site (client)</a></li>
  <li><a data-sveltekit-reload href="/about">About my site (reload)</a></li>
  <li><a href="/search/stocks">Search Stocks (client)</a></li>
  <li><a data-sveltekit-reload href="/search/stocks">Search Stocks (reload)</a></li>
  <li><a href="/sv">SV (client)</a></li>
  <li><a data-sveltekit-reload href="/sv">SV (reload)</a></li>
</ul>
