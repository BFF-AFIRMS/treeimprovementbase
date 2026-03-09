<script lang="ts">
  import { columns } from "./table/columns.js";
  import DataTable from "$lib/components/app/data-table.svelte";
  import * as AlertDialog from "$lib/components/ui/alert-dialog/index.js";
  import { buttonVariants } from "$lib/components/ui/button/index.js";
  import Alert from "./alert.svelte";

  import {programs} from "$lib/brapi/v2";
  let params = {pageSize: 1000000};
  let data = programs(params);

  let caption = "List of breeding programs.";
  let pageSize = 100;
</script>

<h1>Breeding Programs</h1>

<div class="mt-4">

  {#await data }
    <div class="inline-block w-11/12 h-80">
      <DataTable data={[]} {caption} {columns} skeleton={true}/>
    </div>
  {:then response}

    {#if response.result.error}
      <Alert error={response.result.error}/>
    {/if}

    {#if response.result.data.length == 0}
      <div class="inline-block w-11/12 h-80">
        <DataTable data={[]} {caption} {columns} skeleton={false}/>
      </div>
    {:else}
      <div class="inline-block w-11/12 h-[80vh]">
        <DataTable
          data={response.result.data}
          {caption}
          totalCount={response.metadata.pagination.totalCount}
          {pageSize}
          {columns}
          skeleton={false}
        />
      </div>
    {/if}
  {:catch error}
      <Alert error={"An unhandled error occurred. "  + error}/>

      <div class="inline-block w-11/12 h-80">
        <DataTable data={[]} {caption} {columns} skeleton={false}/>
      </div>
  {/await}

</div>
