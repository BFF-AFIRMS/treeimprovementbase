<script lang="ts">

  // Imports
  import Alert from "$lib/components/app/alert.svelte";
  import {Button, buttonVariants} from "$lib/components/ui/button/index.js";
  import { cn } from "$lib/utils.js";
  import { columns } from "./table/columns.js";
  import { Schema as Germplasm, create as createGermplasm } from "$lib/brapi/v2/germplasm";
  import DataTable from "$lib/components/app/data-table.svelte";
  import * as Dialog from "$lib/components/ui/dialog/index.js";
  import * as Field from "$lib/components/ui/field/index.js";
  import { getData, fetchData } from "./table/data.svelte.js";
  import { Input } from "$lib/components/ui/input/index.js";
  import type { PageProps } from './$types';

  let { data }: PageProps = $props();

  // State
  let createData = $state(Germplasm.parse({}));
  let createErrorMessage: string | null = $state(null);
  let createSuccessMessage: string | null = $state(null);
  let createDialogOpen: boolean = $state(false);

  // Table Display Options
  let caption = "List of germplasm.";
  let pageSize = 100;

  async function submitCreateGermplasm(){
    let result = await createGermplasm({germplasm: createData});
    createErrorMessage = result.error;
    createSuccessMessage = result.success;
  }

</script>

<!-- Button to add a new germplasm -->
{#snippet NewGermplasmButton()}
  {#if data.user_role == 'curator' }
  <Button slot="buttons" size="sm" class="btn-primary" onclick={() => {createDialogOpen = true}}>
    Add New Germplasm
  </Button>
  {/if}
{/snippet}

<!-- Table with 'skeleton' rows to indicate data is still loading -->
{#snippet SkeletonTable()}
  <div class="inline-block w-11/12 h-80">
    <DataTable data={[]} {caption} {columns} refreshTable={fetchData} skeleton={true} buttons={NewGermplasmButton}/>
  </div>
{/snippet}

<!-- Table with empty rows that is a bit smaller -->
{#snippet EmptyTable()}
  <div class="inline-block w-11/12 h-80">
    <DataTable data={[]} {caption} {columns} refreshTable={fetchData} skeleton={false} buttons={NewGermplasmButton}/>
  </div>
{/snippet}

<h1>Germplasm</h1>

<hr class="mt-4 mb-8">

<!-- Main Data Table -->
<div class="mt-4">

  <!-- While we're waiting, display a skeleton table -->
  {#await getData()}
    {@render SkeletonTable()}

  <!-- Data query has finished -->
  {:then response}

    {#if response.error}
      <Alert title="Error Fetching Germplasm" description={response.error} open={true}/>
    {/if}

    {#if response.data.result.length == 0}
      {@render EmptyTable()}
    {:else}
      <div class="inline-block w-11/12 h-[70vh]">
        <DataTable
          data={response.data.result}
          {caption}
          totalCount={response.data.result.length}
          {pageSize}
          {columns}
          refreshTable={fetchData}
          buttons={NewGermplasmButton}
          skeleton={false}
        />
      </div>
    {/if}

  <!-- Uh oh, unhandled errors -->
  {:catch error}
      <Alert title="Error Fetching Germplasm" description={"An unhandled error occurred. "  + error}/>
      {@render EmptyTable()}
  {/await}
</div>


<!-- Dialog box to submit a germplasm -->
<Dialog.Root open={createDialogOpen} onOpenChange={() => createDialogOpen = !createDialogOpen}>
  <form method="POST">
    <Dialog.Content class="sm:min-w-[425px] max-w-[425px] md:max-w-[720px]" onkeyup = {(e) => e.key == 'Enter' ? submitCreateGermplasm() : null}>
      <Dialog.Header>
        <Dialog.Title id="addBreedingProgramDialog">Store Breeding Program Details</Dialog.Title>
        <Dialog.Description>
          Add a new germplasm to the database.
        </Dialog.Description>
      </Dialog.Header>
      <Field.Field>
        <Field.Label>Name</Field.Label>
        <Input bind:value={createData.germplasmName} type="text" required/>
      </Field.Field>
      <Field.Field>
        <Field.Label>Species</Field.Label>
        <Input bind:value={createData.species} type="text" required/>
      </Field.Field>
      <Dialog.Footer class="inline-block text-right">
        <Dialog.Close type="button" onclick={() => createDialogOpen = false} class={cn(buttonVariants({ variant: "outline" }), "cursor-pointer")}>
          Close
        </Dialog.Close>
        <Button type="submit" onclick={submitCreateGermplasm} name="store_breeding_program_submit" id="store_breeding_program_submit">Store Breeding Program Details</Button>
      </Dialog.Footer>
    </Dialog.Content>
  </form>
</Dialog.Root>

<!-- Alerts for success/error status of creating a program -->
<Alert
  title="Error Creating New Program"
  description={createErrorMessage}
  open={createErrorMessage}
  onOpenChange={() => {createErrorMessage = null}}
/>

<Alert
  title="Successfully Created New Program."
  description={createSuccessMessage}
  open={createSuccessMessage}
  onOpenChange={() => {createSuccessMessage = null; createDialogOpen = false; fetchData()}}
/>
