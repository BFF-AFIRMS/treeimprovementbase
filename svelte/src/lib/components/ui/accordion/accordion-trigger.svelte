<script lang="ts">
	import { Accordion as AccordionPrimitive } from "bits-ui";
	import Minus from "@lucide/svelte/icons/minus";
	import Plus from "@lucide/svelte/icons/plus";
	import ChevronDownIcon from "@lucide/svelte/icons/chevron-down";
	import { cn, type WithoutChild } from "$lib/utils.js";

	let {
		ref = $bindable(null),
		class: className,
		level = 3,
		children,
		...restProps
	}: WithoutChild<AccordionPrimitive.TriggerProps> & {
		level?: AccordionPrimitive.HeaderProps["level"];
	} = $props();
</script>

<AccordionPrimitive.Header {level} class="flex">
	<AccordionPrimitive.Trigger
		data-slot="accordion-trigger"
		bind:ref
		class={cn(
			"focus-visible:border-ring focus-visible:ring-ring/50 flex flex-1 items-start gap-2 rounded-md py-4 text-start text-sm font-medium transition-all outline-none hover:underline focus-visible:ring-[3px] disabled:pointer-events-none disabled:opacity-50 group",
			className
		)}
		{...restProps}
	>
		<!-- <ChevronDownIcon
			class="text-muted-foreground pointer-events-none size-4 shrink-0 translate-y-0.5 transition-transform duration-200"
		/> -->
		<!-- <div class="text-muted-foreground pointer-events-none size-4 shrink-0 translate-y-0.5 transition-transform duration-200"> -->
		<Plus class="text-muted-foreground pointer-events-none translate-y-0.5 group-data-[state=open]:hidden size-4 border-2 border-muted-foreground rounded-xl"/>
		<Minus class="text-muted-foreground pointer-events-none translate-y-0.5 group-data-[state=closed]:hidden size-4 border-2 border-muted-foreground rounded-xl"/>
		{@render children?.()}
	</AccordionPrimitive.Trigger>
</AccordionPrimitive.Header>
