<script lang="ts">
  import Alert from "$lib/components/app/alert.svelte";
  import { Button, buttonVariants } from "$lib/components/ui/button/index.js";
  import { cn } from "$lib/utils.js";
  import { fetchData } from "./data.svelte.js";
  import * as Dialog from "$lib/components/ui/dialog/index.js";
  import EllipsisIcon from "@lucide/svelte/icons/ellipsis";
  import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";

  let deleteDialogOpen = $state(false);
  let deleteErrorMessage: string | null = $state(null);
  let deleteSuccessMessage: string | null = $state(null);
  $inspect("deleteDialogOpen:", deleteDialogOpen);

  let { name, id }: { name: string, id: Number } = $props();

  async function deleteProgram(options: {id: Number}){
    let url = `/breeders/program/delete/${options.id}`;
    const response = await fetch(url, { method: 'POST'});

    if (response.ok) {
      deleteSuccessMessage = `The breeding program was successfully deleted: ${name}`;
      deleteDialogOpen = false;
      fetchData();
    } else {
      deleteErrorMessage = `Failed to delete the breeding program. ${response.statusText} (${response.status}).`
    }
  }

</script>

<DropdownMenu.Root>
  <DropdownMenu.Trigger>
    {#snippet child({ props })}
      <Button
        {...props}
        variant="ghost"
        size="icon"
        class="relative size-8 p-0"
      >
        <span class="sr-only">Open menu</span>
        <EllipsisIcon />
      </Button>
    {/snippet}
  </DropdownMenu.Trigger>
  <DropdownMenu.Content>
    <DropdownMenu.Item class="cursor-pointer">Edit</DropdownMenu.Item>
    <!-- <DropdownMenu.Separator /> -->
    <DropdownMenu.Item class="text-red-700 hover:text-red-900! cursor-pointer" onclick={() => deleteDialogOpen = true}>Delete</DropdownMenu.Item>
  </DropdownMenu.Content>
</DropdownMenu.Root>

<!-- A dialog box to delete a breeding program -->
<Dialog.Root open={deleteDialogOpen}>
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
      <Button type="submit" onclick={() => deleteProgram({id: id, name: name})}>Delete</Button>
    </Dialog.Footer>
  </Dialog.Content>
</Dialog.Root>


<!-- Alerts to indicate success/error of deleting a breeding program -->
{#if deleteErrorMessage}
  <Alert title="Error Deleting Breeding Program" description={deleteErrorMessage} onDismiss={() => {deleteErrorMessage = null}}/>
{/if}

{#if deleteSuccessMessage}
  <Alert
    title="Successfully Deleted Breeding Program"
    description={deleteSuccessMessage}
    onDismiss={() => {deleteSuccessMessage = null; deleteDialogOpen = false;}}
  />
{/if}
