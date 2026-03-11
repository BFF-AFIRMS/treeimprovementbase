
<script lang="ts">
  import { resolve } from "$app/paths";
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
  <li><a href={resolve("/search/organisms")}>Organisms</a></li>
  <li><a href={resolve("/breeders/manage_programs")}>Breeding Programs</a></li>
</ul>
