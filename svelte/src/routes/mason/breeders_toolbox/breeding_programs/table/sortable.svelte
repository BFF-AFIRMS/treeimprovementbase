<script lang="ts">
  import type { ComponentProps } from "svelte";
  import ArrowUpDownIcon from "@lucide/svelte/icons/arrow-up-down";
  import { Button } from "$lib/components/ui/button/index.js";

  let { variant = "ghost", name = "test", ...restProps }: ComponentProps<typeof Button> = $props();
</script>
<div class="text-center">
<Button {variant} {...restProps} class="mb-2 cursor-pointer w-full bg-secondary">
  {name}
  <ArrowUpDownIcon class="ml-2" />
</Button>
</div>
