<script lang="ts">
	import './layout.css';
	import favicon from '$lib/assets/favicon.svg';
	import {App} from '$lib/components/app';

	let { children } = $props();
</script>

<svelte:head><link rel="icon" href={favicon} /></svelte:head>
<App>
{@render children()}
</App>