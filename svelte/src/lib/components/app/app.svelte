<script lang="ts">
	let { children } = $props();
    import Navbar from "$lib/components/app/navbar.svelte";
</script>

<div style="text-align: center">
    <!--  style="min-width: var(--breakpoint-xs); max-width: var(--breakpoint-lg)" -->
      <!-- inline-grid -->
    <div class="overflow-auto w-full h-screen"  style="min-width: var(--breakpoint-xs)">
        <Navbar/>
        {@render children()}
    </div>
</div>
