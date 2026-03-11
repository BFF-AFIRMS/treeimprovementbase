<script lang="ts">

  // Imports
  import Alert from "$lib/components/app/alert.svelte";
  import { Button, buttonVariants } from "$lib/components/ui/button/index.js";
  import { cn } from "$lib/utils.js";
  import { fetchData } from "./data.svelte.js";
  import * as Dialog from "$lib/components/ui/dialog/index.js";
  import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";
  import * as Field from "$lib/components/ui/field/index.js";
  import EllipsisIcon from "@lucide/svelte/icons/ellipsis";
  import { Input } from "$lib/components/ui/input/index.js";
  import { deleteProgram, editProgram, ProgramSchema } from "$lib/breedbase/program.js";

  // States
  let deleteDialogOpen = $state(false);
  let deleteErrorMessage: string | null = $state(null);
  let deleteSuccessMessage: string | null = $state(null);

  let editDialogOpen = $state(false);
  let editErrorMessage: string | null = $state(null);
  let editSuccessMessage: string | null = $state(null);

  // Props
  let { id, name, desc }: { id: Number, name: string, desc: string  } = $props();
  let program = $derived(ProgramSchema.parse({id: id, name: name, desc: desc}));

  async function submitDeleteProgram(){
    console.log("submitDeleteProgram");
    let result = await deleteProgram({program: program});
    deleteErrorMessage = result.error;
    deleteSuccessMessage = result.success;
    if (result.error) {
      deleteDialogOpen = false;
    }
  }

  async function submitEditProgram(){
    let result = await editProgram({program: program});
    editErrorMessage = result.error;
    editSuccessMessage = result.success;
  }

</script>

<!-- Dropdown Menu for Row Actions -->
<DropdownMenu.Root>
  <DropdownMenu.Trigger>
    {#snippet child({ props })}
      <Button {...props} variant="ghost" size="icon" class="relative size-8 p-0">
        <span class="sr-only">Open menu</span>
        <EllipsisIcon />
      </Button>
    {/snippet}
  </DropdownMenu.Trigger>
  <DropdownMenu.Content>
    <DropdownMenu.Item class="cursor-pointer" onclick={() => editDialogOpen = true}>Edit</DropdownMenu.Item>
    <DropdownMenu.Item class="text-red-700 hover:text-red-900! cursor-pointer" onclick={() => deleteDialogOpen = true}>Delete</DropdownMenu.Item>
  </DropdownMenu.Content>
</DropdownMenu.Root>

<!-- Dialog box to delete a breeding program -->
<Dialog.Root open={deleteDialogOpen} onOpenChange={() => deleteDialogOpen = !deleteDialogOpen}>
  <Dialog.Content class="sm:min-w-[425px] max-w-[425px]">
    <Dialog.Header>
      <Dialog.Title>Delete Breeding Program</Dialog.Title>
      <Dialog.Description>
        Delete breeding program {name}? The associated trials will not be deleted, but be listed under 'Other'
      </Dialog.Description>
    </Dialog.Header>
    <Dialog.Footer class="inline-block text-right">
      <Dialog.Close type="button" onclick={() => deleteDialogOpen = false} class={cn(buttonVariants({ variant: "outline" }), "cursor-pointer")}>
        Cancel
      </Dialog.Close>
      <Button type="submit" onclick={submitDeleteProgram}>Submit</Button>
    </Dialog.Footer>
  </Dialog.Content>
</Dialog.Root>


<!-- Alerts to indicate success/error of deleting a breeding program -->
<Alert
  title="Error Deleting Breeding Program"
  description={deleteErrorMessage}
  onOpenChange={() => {deleteErrorMessage = null}}
  open={deleteErrorMessage}
/>
<Alert
  title="Successfully Deleted Breeding Program"
  description={deleteSuccessMessage}
  onOpenChange={() => {deleteSuccessMessage = null; deleteDialogOpen = false;  fetchData(); }}
  open={deleteSuccessMessage}
/>

<!-- Dialog box to edit a breeding program -->
<Dialog.Root open={editDialogOpen} onOpenChange={() => editDialogOpen = !editDialogOpen}>
  <form method="POST">
    <Dialog.Content class="sm:min-w-[425px] max-w-[425px] md:max-w-[720px]">
      <Dialog.Header>
        <Dialog.Title id="addBreedingProgramDialog">Edit Breeding Program Details</Dialog.Title>
        <Dialog.Description>
          Edit a new breeding programs details.
        </Dialog.Description>
      </Dialog.Header>
      <Field.Field>
        <Field.Label>Name</Field.Label>
        <Input bind:value={name} type="text" required/>
      </Field.Field>
      <Field.Field>
        <Field.Label>Description</Field.Label>
        <Input bind:value={desc} type="text" required/>
      </Field.Field>
      <Dialog.Footer class="inline-block text-right">
        <Dialog.Close type="button" onclick={() => editDialogOpen = false} class={cn(buttonVariants({ variant: "outline" }), "cursor-pointer")}>
          Close
        </Dialog.Close>
        <Button type="submit" onclick={submitEditProgram}>Submit</Button>
      </Dialog.Footer>
    </Dialog.Content>
  </form>
</Dialog.Root>

<!-- Alerts to indicate success/error of editing a breeding program -->
<Alert
  title="Error Editing Breeding Program"
  description={editErrorMessage}
  onOpenChange={() => {editErrorMessage = null}}
  open={editErrorMessage}
/>
<Alert
  title="Successfully Edited Breeding Program"
  description={editSuccessMessage}
  onOpenChange={() => {editSuccessMessage = null; editDialogOpen = false; fetchData(); }}
  open={editSuccessMessage}
/>
