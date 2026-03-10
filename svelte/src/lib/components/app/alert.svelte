<script lang="ts">
  import * as AlertDialog from "$lib/components/ui/alert-dialog/index.js";
  import { buttonVariants } from "$lib/components/ui/button/index.js";

  let { description, title, onDismiss } = $props();
</script>


<AlertDialog.Root open={true}>
<AlertDialog.Content>
    <AlertDialog.Header>
    <AlertDialog.Title>{title}</AlertDialog.Title>
    <AlertDialog.Description>
        {description}
    </AlertDialog.Description>
    </AlertDialog.Header>
    <AlertDialog.Footer>
    {#if onDismiss}
        <AlertDialog.Cancel class={buttonVariants({ variant: "default" })} onclick={onDismiss}>Ok</AlertDialog.Cancel>
    {:else}
        <AlertDialog.Cancel class={buttonVariants({ variant: "default" })}>Ok</AlertDialog.Cancel>
    {/if}
    </AlertDialog.Footer>
</AlertDialog.Content>
</AlertDialog.Root>
