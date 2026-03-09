<script lang="ts">
	import './layout.css';
	import favicon from '$lib/assets/favicon.svg';
	import {App} from '$lib/components/app';
	let { children } = $props();
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<link rel="stylesheet" href="https://rsms.me/inter/inter.css" />
</svelte:head>

<App>
{@render children()}
</App>
