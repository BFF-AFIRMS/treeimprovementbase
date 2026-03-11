<script lang="ts">
  import * as AlertDialog from "$lib/components/ui/alert-dialog/index.js";
  import { buttonVariants } from "$lib/components/ui/button/index.js";

  let { description, title, onOpenChange = null, open = false

   } = $props();
</script>


<AlertDialog.Root open={open} onOpenChange={onOpenChange}>
<AlertDialog.Content>
    <AlertDialog.Header>
    <AlertDialog.Title>{title}</AlertDialog.Title>
    <AlertDialog.Description>
        {description}
    </AlertDialog.Description>
    </AlertDialog.Header>
    <AlertDialog.Footer>
    <AlertDialog.Cancel class={buttonVariants({ variant: "default" })}>Ok</AlertDialog.Cancel>
    </AlertDialog.Footer>
</AlertDialog.Content>
</AlertDialog.Root>
