<script lang="ts">

  // Imports
  import Alert from "$lib/components/app/alert.svelte";
  import {Button, buttonVariants} from "$lib/components/ui/button/index.js";
  import { cn } from "$lib/utils.js";
  import { columns } from "./table/columns.js";
  import { fetchData, getData } from "./table/data.svelte.js";
  import DataTable from "$lib/components/app/data-table.svelte";
  import * as Dialog from "$lib/components/ui/dialog/index.js";
  import * as Field from "$lib/components/ui/field/index.js";
  import { Input } from "$lib/components/ui/input/index.js";
  import { ProgramSchema, createProgram } from "$lib/breedbase/program.js";

  // State
  let createData = $state(ProgramSchema.parse({}));
  let createErrorMessage: string | null = $state(null);
  let createSuccessMessage: string | null = $state(null);
  let createDialogOpen: boolean = $state(false);

  $inspect("createErrorMessage:", createErrorMessage);
  $inspect("createSuccessMessage:", createSuccessMessage);

  // Table Display Options
  let caption = "List of breeding programs.";
  let pageSize = 100;

  async function submitCreateProgram(){
    let result = await createProgram({program: createData});
    createErrorMessage = result.error;
    createSuccessMessage = result.success;
  }
</script>

<!-- Button to add a new program -->
{#snippet NewProgramButton()}
  <Button slot="buttons" size="sm" class="btn-primary" name="new_breeding_program_link" id="new_breeding_program_link" onclick={() => {createDialogOpen = true}}>
    Add New Program
  </Button>
{/snippet}

<!-- Table with 'skeleton' rows to indicate data is still loading -->
{#snippet SkeletonTable()}
  <div class="inline-block w-11/12 h-80">
    <DataTable data={[]} {caption} {columns} refreshTable={fetchData} skeleton={true} buttons={NewProgramButton}/>
  </div>
{/snippet}

<!-- Table with empty rows that is a bit smaller -->
{#snippet EmptyTable()}
  <div class="inline-block w-11/12 h-80">
    <DataTable data={[]} {caption} {columns} refreshTable={fetchData} skeleton={false} buttons={NewProgramButton}/>
  </div>
{/snippet}

<h1>Breeding Programs</h1>

<hr class="mt-4 mb-8">

<!-- Main Data Table -->
<div class="mt-4">

  <!-- While we're waiting, display a skeleton table -->
  {#await getData() }
    {@render SkeletonTable()}

  <!-- Data query has finished -->
  {:then response}

    {#if response.result.error}
      <Alert title="Error Fetching Programs" description={response.result.error}/>
    {/if}

    {#if response.result.data.length == 0}
      {@render EmptyTable()}
    {:else}
      <div class="inline-block w-11/12 h-[70vh]">
        <DataTable
          data={response.result.data}
          {caption}
          totalCount={response.metadata.pagination.totalCount}
          {pageSize}
          {columns}
          refreshTable={fetchData}
          buttons={NewProgramButton}
          skeleton={false}
        />
      </div>
    {/if}

  <!-- Uh oh, unhandled errors -->
  {:catch error}
      <Alert title="Error Fetching Programs" description={"An unhandled error occurred. "  + error}/>
      {@render EmptyTable()}
  {/await}
</div>

<!-- Dialog box to submit a breeding program -->
<Dialog.Root open={createDialogOpen} onOpenChange={() => createDialogOpen = !createDialogOpen}>
  <form method="POST">
    <Dialog.Content class="sm:min-w-[425px] max-w-[425px] md:max-w-[720px]">
      <Dialog.Header>
        <Dialog.Title id="addBreedingProgramDialog">Store Breeding Program Details</Dialog.Title>
        <Dialog.Description>
          Add a new breeding program to the database.
        </Dialog.Description>
      </Dialog.Header>
      <Field.Field>
        <Field.Label for="store_breeding_program_name">Name</Field.Label>
        <Input bind:value={createData.name} name="store_breeding_program_name" id="store_breeding_program_name" type="text" required/>
      </Field.Field>
      <Field.Field>
        <Field.Label for="store_breeding_program_desc">Description</Field.Label>
        <Input bind:value={createData.desc} name="store_breeding_program_desc" id="store_breeding_program_desc" type="text" required/>
      </Field.Field>
      <Dialog.Footer class="inline-block text-right">
        <Dialog.Close type="button" onclick={() => createDialogOpen = false} class={cn(buttonVariants({ variant: "outline" }), "cursor-pointer")}>
          Close
        </Dialog.Close>
        <Button type="submit" name="store_breeding_program_submit" id="store_breeding_program_submit" onclick={submitCreateProgram}>Store Breeding Program Details</Button>
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
