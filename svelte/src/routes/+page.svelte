
<script lang="ts">
  import { Button } from "$lib/components/ui/button/index.js";
  import * as Accordion from "$lib/components/ui/accordion/index.js";
  import * as AlertDialog from "$lib/components/ui/alert-dialog/index.js";
  import { buttonVariants } from "$lib/components/ui/button/index.js";
</script>

<h2>Routing</h2>

<ul>
  <li><a href="/about">About my site (client)</a></li>
  <li><a data-sveltekit-reload href="/about">About my site (reload)</a></li>
  <li><a href="/search/stocks">Search Stocks (client)</a></li>
  <li><a data-sveltekit-reload href="/search/stocks">Search Stocks (reload)</a></li>
  <li><a href="/sv">SV (client)</a></li>
  <li><a data-sveltekit-reload href="/sv">SV (reload)</a></li>
  <li><a href="/sv/organisms">Organisms Old</a></li>
</ul>

<h2>Mason</h2>

<ul>
  <li><a href="/mason/search/organism">Organisms</a></li>
  <li><a href="/mason/breeders_toolbox/breeding_programs">Breeding Programs</a></li>
</ul>
