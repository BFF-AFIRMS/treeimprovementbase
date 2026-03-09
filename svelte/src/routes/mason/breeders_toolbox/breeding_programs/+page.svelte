<script lang="ts">

  import Alert from "./alert.svelte";
  import {Button, buttonVariants} from "$lib/components/ui/button/index.js";
  import { columns } from "./table/columns.js";
  import DataTable from "$lib/components/app/data-table.svelte";
  import * as Dialog from "$lib/components/ui/dialog/index.js";
  import { Input } from "$lib/components/ui/input/index.js";
  import * as Field from "$lib/components/ui/field/index.js";
  import { programs } from "$lib/brapi/v2";
  import { z } from 'zod';

  // Fetch program
  let params = {pageSize: 1000000};
  let data = $state(programs(params));
  let caption = "List of breeding programs.";
  let pageSize = 100;

  // Submit program data
  let submit_name: string | null = $state(null);
  let submit_description: string | null = $state(null);
  let submit_error: string | null = $state(null);
  let submit_success: string | null = $state(null);
  let submitDialogOpen: boolean = $state(false);

  function refreshTable() {
    data = programs(params);
  }

  async function submitNewProgram() {

    // Input validation
    const submitSchema = z.object({
        name: z.string({
          error: (iss) => iss.input == null ? "Name is a required field." : "Name is invalid."
        }),
        desc: z.string({
          error: (iss) => iss.input == null ? "Description is a required field." : "Description is invalid."
        }),
      });
    let result = submitSchema.safeParse({'name': submit_name, 'desc': submit_description});
    if (!result.success) {
      let submit_errors: string[] = [];
      result.error.issues.forEach((issue) => {
        submit_errors.push(issue.message);
      })
      submit_error = submit_errors.join(" ");
    } else {
      // Post the valid data
      const query = new URLSearchParams(result.data).toString();
      let url = `/breeders/program/store?${query}`;
      const response = await fetch(url, { method: 'POST'});
      console.log("response:", response);

      if (response.ok) {
        submit_success = `The new breeding program was successfully submitted: ${result.data.name}`;
        submitDialogOpen = false;
        refreshTable();
      } else {
        submit_error = `Failed to upload the new breeding program. ${response.statusText} (${response.status}).`
      }
    }
  }

</script>

<h1>Breeding Programs</h1>

<hr class="mb-4">

<div class="inline-block w-11/12 text-left">

</div>

<!-- Main Data Table -->

<div class="mt-4">

  {#await data }
    <div class="inline-block w-11/12 h-80">
      <DataTable data={[]} {caption} {columns} {refreshTable} skeleton={true}>
        <Button slot="buttons" size="sm" class="btn-primary ml-4" name="new_breeding_program_link" id="new_breeding_program_link" onclick={() => {submitDialogOpen = true}}>
            Add New Program
        </Button>
      </DataTable>
    </div>
  {:then response}

    {#if response.result.error}
      <Alert title="Error Fetching Programs" description={response.result.error}/>
    {/if}

    {#if response.result.data.length == 0}
      <div class="inline-block w-11/12 h-80">
        <DataTable data={[]} {caption} {columns} {refreshTable} skeleton={false}>
          <Button slot="buttons" size="sm" class="btn-primary ml-4" name="new_breeding_program_link" id="new_breeding_program_link" onclick={() => {submitDialogOpen = true}}>
              Add New Program
          </Button>
        </DataTable>
      </div>
    {:else}
      <div class="inline-block w-11/12 h-[70vh]">
        <DataTable
          data={response.result.data}
          {caption}
          totalCount={response.metadata.pagination.totalCount}
          {pageSize}
          {columns}
          {refreshTable}
          skeleton={false}
        >
          <Button slot="buttons" size="sm" class="btn-primary ml-4" name="new_breeding_program_link" id="new_breeding_program_link" onclick={() => {submitDialogOpen = true}}>
              Add New Program
          </Button>
        </DataTable>
      </div>
    {/if}
  {:catch error}
      <Alert title="Error Fetching Programs" description={"An unhandled error occurred. "  + error}/>

      <div class="inline-block w-11/12 h-80">
        <DataTable data={[]} {caption} {columns} {refreshTable} skeleton={false}>
          <Button slot="buttons" size="sm" class="btn-primary ml-4" name="new_breeding_program_link" id="new_breeding_program_link" onclick={() => {submitDialogOpen = true}}>
              Add New Program
          </Button>
        </DataTable>
      </div>
  {/await}
</div>

<!-- Dialog box for errors when submitting a new program -->

<Dialog.Root open={submitDialogOpen}>
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
        <Input bind:value={submit_name} name="store_breeding_program_name" id="store_breeding_program_name" type="text" required/>
      </Field.Field>
      <Field.Field>
        <Field.Label for="store_breeding_program_desc">Description</Field.Label>
        <Input bind:value={submit_description} name="store_breeding_program_desc" id="store_breeding_program_desc" type="text" required/>
      </Field.Field>
      <Dialog.Footer class="inline-block text-right">
        <Dialog.Close type="button" class={buttonVariants({ variant: "outline" })}>
          Close
        </Dialog.Close>
        <Button type="submit" onclick={submitNewProgram}>Store Breeding Program Details</Button>
      </Dialog.Footer>
    </Dialog.Content>
  </form>
</Dialog.Root>

{#if submit_error}
  <Alert title="Error Submitting New Program" description={submit_error} onDismiss={() => {submit_error = null}}/>
{/if}

{#if submit_success}
  <Alert
    title="Successfully Submitted New Program."
    description={submit_success}
    onDismiss={() => {submit_success = null; submitDialogOpen = false;}}
  />
{/if}
