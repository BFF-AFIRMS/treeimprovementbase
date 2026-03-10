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
  import { PUBLIC_BREEDBASE_URL } from '$env/static/public';
  import { z } from 'zod';

  // Program submission schema
  const ProgramSchema = z.object({
      name: z.string().nullable().default(null),
      desc: z.string().nullable().default(null),
    }).default({});

  // Program submission validation rules
  const ProgramValidator = z.object({
      name: z.string({ error: (iss) => iss.input == null ? "Name is a required field." : "Name is invalid." }),
      desc: z.string({ error: (iss) => iss.input == null ? "Description is a required field." : "Description is invalid." })
    });

  // State
  let submitData = $state(ProgramSchema.parse({}));
  let submitErrorMessage: string | null = $state(null);
  let submitSuccessMessage: string | null = $state(null);
  let submitDialogOpen: boolean = $state(false);

  // Fetch data
  let caption = "List of breeding programs.";
  let pageSize = 100;

  // Submit a new breeding program to the database
  async function submitNewProgram() {

    // Input validation
    let result = ProgramValidator.safeParse(submitData);
    if (!result.success) {
      let submitErrorMessages: string[] = [];
      result.error.issues.forEach((issue) => {
        submitErrorMessages.push(issue.message);
      })
      submitErrorMessage = submitErrorMessages.join(" ");
    } else {
      // Post the valid data
      const query = new URLSearchParams(result.data).toString();
      let url = `${PUBLIC_BREEDBASE_URL}/breeders/program/store?${query}`;
      const response = await fetch(url, { method: 'POST'});
      console.log("response:", response);

      if (!response.ok){
        submitErrorMessage = `Failed to upload the new breeding program. ${response.statusText} (${response.status}).`
        return;
      }

      if (response.ok) {
        // Check if we have an error message
        let result = await response.json();
        if (result.error) {
          submitErrorMessage = `Failed to upload the new breeding program. ${result.error}`
          return;
        } else {
          submitSuccessMessage = `The new breeding program was successfully submitted: ${result.data.name}`;
          submitDialogOpen = false;
          fetchData();
          return
        }
      }
    }
  }

</script>

<h1>Breeding Programs</h1>

<hr class="mt-4 mb-8">

<!-- Main Data Table -->

<div class="mt-4">

  {#await getData() }
    <div class="inline-block w-11/12 h-80">
      <DataTable data={[]} {caption} {columns} refreshTable={fetchData} skeleton={true}>
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
        <DataTable data={[]} {caption} {columns} refreshTable={fetchData} skeleton={false}>
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
          refreshTable={fetchData}
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
        <DataTable data={[]} {caption} {columns} refreshTable={fetchData} skeleton={false}>
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
        <Input bind:value={submitData.name} name="store_breeding_program_name" id="store_breeding_program_name" type="text" required/>
      </Field.Field>
      <Field.Field>
        <Field.Label for="store_breeding_program_desc">Description</Field.Label>
        <Input bind:value={submitData.desc} name="store_breeding_program_desc" id="store_breeding_program_desc" type="text" required/>
      </Field.Field>
      <Dialog.Footer class="inline-block text-right">
        <Dialog.Close type="button" onclick={() => submitDialogOpen = false} class={cn(buttonVariants({ variant: "outline" }), "cursor-pointer")}>
          Close
        </Dialog.Close>
        <Button type="submit" onclick={submitNewProgram}>Store Breeding Program Details</Button>
      </Dialog.Footer>
    </Dialog.Content>
  </form>
</Dialog.Root>

{#if submitErrorMessage}
  <Alert title="Error Submitting New Program" description={submitErrorMessage} onDismiss={() => {submitErrorMessage = null}}/>
{/if}

{#if submitSuccessMessage}
  <Alert
    title="Successfully Submitted New Program."
    description={submitSuccessMessage}
    onDismiss={() => {submitSuccessMessage = null; submitDialogOpen = false;}}
  />
{/if}
