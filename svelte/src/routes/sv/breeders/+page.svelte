<script lang="ts">
  import { columns } from "./table/columns.js";
  import DataTable from "$lib/components/app/data-table.svelte";

  let { data } = $props();
</script>

<h1>Breeding Programs</h1>

{#await data.promise }
	<DataTable
    data={[]}
    caption="List of breeding programs."
    {columns}
    skeleton={true}
  />
{:then response}
    <DataTable
    data={response.result.data}
    caption="List of breeding programs."
    totalCount={response.metadata.pagination.totalCount}
    pageSize={10}
    {columns}
    skeleton={false}
  />
{:catch error}
  Error!
{/await}
