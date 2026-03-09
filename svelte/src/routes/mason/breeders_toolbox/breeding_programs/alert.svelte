<script lang="ts">
  import * as AlertDialog from "$lib/components/ui/alert-dialog/index.js";
  import { buttonVariants } from "$lib/components/ui/button/index.js";

  let { error } = $props();
</script>


<AlertDialog.Root open={true}>
<AlertDialog.Content>
    <AlertDialog.Header>
    <AlertDialog.Title>Error Fetching Programs</AlertDialog.Title>
    <AlertDialog.Description>
        {error}
    </AlertDialog.Description>
    </AlertDialog.Header>
    <AlertDialog.Footer>
    <AlertDialog.Cancel class={buttonVariants({ variant: "default" })}>Ok</AlertDialog.Cancel>
    </AlertDialog.Footer>
</AlertDialog.Content>
</AlertDialog.Root>
