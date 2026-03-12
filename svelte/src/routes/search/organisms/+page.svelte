<script lang="ts">

  // Imports
  import Alert from "$lib/components/app/alert.svelte";
  import {Button, buttonVariants} from "$lib/components/ui/button/index.js";
  import { cn } from "$lib/utils.js";
  import { columns } from "./table/columns.js";
  import { Schema as Organism } from "$lib/breedbase/organism";
  import DataTable from "$lib/components/app/data-table.svelte";
  import * as Dialog from "$lib/components/ui/dialog/index.js";
  import * as Field from "$lib/components/ui/field/index.js";
  import { getData, fetchData } from "./table/data.svelte.js";
  import { Input } from "$lib/components/ui/input/index.js";
	import type { PageProps } from './$types';

	let { data }: PageProps = $props();

  // State
  let createData = $state(Organism.parse({}));
  let createErrorMessage: string | null = $state(null);
  let createSuccessMessage: string | null = $state(null);
  let createDialogOpen: boolean = $state(false);

  // Table Display Options
  let caption = "List of organisms.";
  let pageSize = 100;

  // async function submitCreateOrganism(){
  //   let result = await createOrganism({program: createData});
  //   createErrorMessage = result.error;
  //   createSuccessMessage = result.success;
  // }

</script>

<!-- Button to add a new organism -->
{#snippet NewOrganismButton()}
  {#if data.user_role == 'curator' }
  <Button slot="buttons" size="sm" class="btn-primary" onclick={() => {createDialogOpen = true}}>
    Add New Organism
  </Button>
  {/if}
{/snippet}

<!-- Table with 'skeleton' rows to indicate data is still loading -->
{#snippet SkeletonTable()}
  <div class="inline-block w-11/12 h-80">
    <DataTable data={[]} {caption} {columns} refreshTable={fetchData} skeleton={true} buttons={NewOrganismButton}/>
  </div>
{/snippet}

<!-- Table with empty rows that is a bit smaller -->
{#snippet EmptyTable()}
  <div class="inline-block w-11/12 h-80">
    <DataTable data={[]} {caption} {columns} refreshTable={fetchData} skeleton={false} buttons={NewOrganismButton}/>
  </div>
{/snippet}

<h1>Organisms</h1>

<hr class="mt-4 mb-8">

<!-- Main Data Table -->
<div class="mt-4">

  <!-- While we're waiting, display a skeleton table -->
  {#await getData()}
    {@render SkeletonTable()}

  <!-- Data query has finished -->
  {:then response}

    {#if response.error}
      <Alert title="Error Fetching Organisms" description={response.error} open={true}/>
    {/if}

    {#if response.data.length == 0}
      {@render EmptyTable()}
    {:else}
      <div class="inline-block w-11/12 h-[70vh]">
        <DataTable
          data={response.data}
          {caption}
          totalCount={response.data.length}
          {pageSize}
          {columns}
          refreshTable={fetchData}
          buttons={NewOrganismButton}
          skeleton={false}
        />
      </div>
    {/if}

  <!-- Uh oh, unhandled errors -->
  {:catch error}
      <Alert title="Error Fetching Organisms" description={"An unhandled error occurred. "  + error}/>
      {@render EmptyTable()}
  {/await}
</div>


<!-- Alerts for success/error status of creating a program -->
<Alert
  title="Error Creating New Organism"
  description={createErrorMessage}
  open={createErrorMessage}
  onOpenChange={() => {createErrorMessage = null}}
/>

<Alert
  title="Successfully Created New Organism"
  description={createSuccessMessage}
  open={createSuccessMessage}
  onOpenChange={() => {createSuccessMessage = null; createDialogOpen = false; fetchData()}}
/>
