<script lang="ts">
  import { cn } from "$lib/utils.js";
  import type { ComponentProps } from "svelte";
  import ArrowUpDownIcon from "@lucide/svelte/icons/arrow-up-down";
  import { Button } from "$lib/components/ui/button/index.js";

  let { variant = "ghost", name = "test", class: className, ...restProps }: ComponentProps<typeof Button> = $props();
</script>
<div class="text-center">
<Button {variant} {...restProps} class={cn("mb-2 cursor-pointer w-full bg-secondary", className)}>
  {name}
  <ArrowUpDownIcon class="ml-2" />
</Button>
</div>
