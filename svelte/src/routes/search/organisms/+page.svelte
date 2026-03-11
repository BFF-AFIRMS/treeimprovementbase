<script lang="ts">
    // Imports
    import Alert from "$lib/components/app/alert.svelte";
    import { fetchData, getData } from "./table/data.svelte.js";
</script>

<h1>Organism/Taxon Search</h1>

<hr class="mt-4 mb-8">

<!-- Main Data Table -->
<div class="mt-4">

  <!-- While we're waiting, display a skeleton table -->
  {#await getData() }
    Rendering skeleton table!

  <!-- Data query has finished -->
  {:then response}

    {#if response.result.error}
      <Alert title="Error Fetching Organisms" description={response.result.error}/>
    {/if}

    {#if response.result.data.length == 0}
      Rendering empty table!
    {:else}
      <div class="inline-block w-11/12 h-[70vh]">
        Rendering full table!
      </div>
    {/if}

  <!-- Uh oh, unhandled errors -->
  {:catch error}
      <Alert title="Error Fetching Organisms" description={"An unhandled error occurred. "  + error}/>
      Rendering empty table!
  {/await}
</div>
