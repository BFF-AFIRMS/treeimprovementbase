<script lang="ts">
	import './layout.css';
	import { asset } from '$app/paths';
	import {App} from '$lib/components/app';
	let { children } = $props();
</script>

<svelte:head>
	<link rel="icon" href={asset("/favicon.ico")} />
	<link rel="stylesheet" href="https://rsms.me/inter/inter.css" />
</svelte:head>

<App>
{@render children()}
</App>
