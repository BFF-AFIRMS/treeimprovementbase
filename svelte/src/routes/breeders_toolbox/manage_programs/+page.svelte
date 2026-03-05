<script lang="ts">
  import { columns } from "./table/columns.js";
  import DataTable from "$lib/components/app/data-table.svelte";

  let { data } = $props();
</script>

<h1>Breeding Programs</h1>

<div>

  <div class="inline-block w-11/12 h-[80vh]">
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
        pageSize={100}
        {columns}
        skeleton={false}
      />
    {:catch error}
      Error!
    {/await}
  </div>

</div>
