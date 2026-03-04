<script lang="ts">
	let { children } = $props();
</script>

<div style="text-align: center">
    <div class="border border-green-800 rounded-xl p-4 overflow-auto inline-grid w-full h-screen"  style="min-width: var(--breakpoint-xs); max-width: var(--breakpoint-lg)">
        {@render children()}
    </div>
</div>
