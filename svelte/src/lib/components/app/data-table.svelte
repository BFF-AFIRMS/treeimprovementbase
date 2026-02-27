<script lang="ts" generics="TData, TValue">
  import { setContext } from 'svelte';
  import { MediaQuery } from "svelte/reactivity";
  import * as Pagination from "$lib/components/ui/pagination/index.js";
  const isDesktop = new MediaQuery("(min-width: 768px)");
  const siblingCount = $derived(isDesktop.current ? 1 : 0);

  import {
    type ColumnDef,
    type PaginationState,
    type SortingState,
    type ColumnFiltersState,
    type RowSelectionState,
    getCoreRowModel,
    getPaginationRowModel,
    getSortedRowModel,
    getFilteredRowModel,
  } from "@tanstack/table-core";

  import {
    createSvelteTable,
    FlexRender,
  } from "$lib/components/ui/data-table/index.js";

  import * as Table from "$lib/components/ui/table/index.js";
  import { Input } from "$lib/components/ui/input/index.js";
  import * as Select from "$lib/components/ui/select/index.js";
  import {Skeleton } from "$lib/components/ui/skeleton/index.js";

  import { renderComponent } from "$lib/components/ui/data-table/index.js";

  type DataTableProps<TData, TValue> = {
    columns: ColumnDef<TData, TValue>[];
    data: TData[];
    caption: String;
    totalCount: number,
    pageSize: number,
    currentPage: Number,
    skeleton: boolean
  };

  let { data, columns, caption, totalCount, pageSize=10, currentPage=0, skeleton=false }: DataTableProps<TData, TValue> = $props();

  // if (skeleton == true) {
  //   columns.forEach(function (column, i){
  //     columns[i].cell = () => {
  //       return renderComponent(Skeleton, {class: "h-[20px] w-full rounded-sm bg-gray-200"});
  //     };
  //     data = [{}];
  //   })
  // }

  let pagination = $state<PaginationState>({ pageIndex: currentPage, pageSize: pageSize });
  let sorting = $state<SortingState>([]);
  let columnFilters = $state<ColumnFiltersState>([]);
  let rowSelection = $state<RowSelectionState>({});

  const table = createSvelteTable({
    get data() {
      return data;
    },
    columns,
    getCoreRowModel: getCoreRowModel(),
    getPaginationRowModel: getPaginationRowModel(),
    getSortedRowModel: getSortedRowModel(),
    getFilteredRowModel: getFilteredRowModel(),
    state: {
      get pagination()    { return pagination; },
      get sorting()       { return sorting; },
      get columnFilters() { return columnFilters; },
      get rowSelection()  { return rowSelection; },
    },
    onPaginationChange: (updater) => {
      if (typeof updater === "function") { pagination = updater(pagination); }
      else { pagination = updater; }
    },
    onSortingChange: (updater) => {
      if (typeof updater === "function"){ sorting = updater(sorting); }
      else { sorting = updater; }
    },
    onColumnFiltersChange: (updater) => {
      if (typeof updater === "function") {
        columnFilters = updater(columnFilters);
      } else {
        columnFilters = updater;
      }
    },
    onRowSelectionChange: (updater) => {
      if (typeof updater === "function") {
        rowSelection = updater(rowSelection);
      } else {
        rowSelection = updater;
      }
    },
  });

  const fruits = [
    { value: 1, label: "1" },
    { value: 5, label: "5" },
    { value: 10, label: "10" },
  ];

  let value = $state("1");

  const triggerContent = $derived(
    fruits.find((f) => f.value === value)?.label ?? "Rows"
  );
</script>

<div>
    <div class="rounded-md border shadow-sm p-2">
    <!-- Table-->
    <Table.Root>
        <Table.Caption class="text-xs mb-1">{caption}</Table.Caption>
        <Table.Header>
        {#each table.getHeaderGroups() as headerGroup (headerGroup.id)}
            <Table.Row>
            {#each headerGroup.headers as header (header.id)}
                <Table.Head colspan={header.colSpan}>
                {#if !header.isPlaceholder}
                    <FlexRender
                    content={header.column.columnDef.header}
                    context={header.getContext()}
                    />
                    {#if header.column.columnDef.enableColumnFilter}
                    <!-- Filter Input Below -->
                    <div class="text-center">
                      <Input
                      placeholder="..."
                      class="w-full h-7 mb-2 text-xs! inline"
                      value={(table.getColumn(header.id)?.getFilterValue() as string) ?? ""}
                      onchange={(e) => { table.getColumn(header.id)?.setFilterValue(e.currentTarget.value); }}
                      oninput={(e) => { table.getColumn(header.id)?.setFilterValue(e.currentTarget.value); }}
                      />
                    </div>
                    {/if}
                {/if}
                </Table.Head>
            {/each}
            </Table.Row>
        {/each}
        </Table.Header>
        <Table.Body>
        {#if skeleton}
          <Table.Row>
          {#each columns as column}
            <Table.Cell>
                  <Skeleton class="h-[20px] w-full rounded-sm bg-gray-400 opacity-5"/>
            </Table.Cell>
          {/each}
          </Table.Row>

        {:else}
          {#each table.getRowModel().rows as row (row.id)}
              <Table.Row data-state={row.getIsSelected() && "selected"}>
              {#each row.getVisibleCells() as cell (cell.id)}
                  <Table.Cell>
                  <FlexRender
                      content={cell.column.columnDef.cell}
                      context={cell.getContext()}
                  />
                  </Table.Cell>
              {/each}
              </Table.Row>
          {:else}
              <Table.Row>
              <Table.Cell colspan={columns.length} class="h-24 text-center">
                  No results.
              </Table.Cell>
              </Table.Row>
          {/each}
        {/if}
        </Table.Body>
    </Table.Root>
    </div>


<div class="flex items-center justify-between px-2">
  <div class="text-muted-foreground flex-1 text-xs text-left">
    {table.getFilteredSelectedRowModel().rows.length} of{" "}
    {table.getFilteredRowModel().rows.length} row(s) selected.
  </div>

  <div class="flex items-center space-x-6 lg:space-x-4"><div class="flex items-center space-x-2">
    <span class="text-muted-foreground text-xs">Rows per page</span>
        <Select.Root type="single" name="favoriteFruit" bind:value>
          <Select.Trigger class="w-[180px]">
            {triggerContent}
          </Select.Trigger>
          <Select.Content>
            <Select.Group>
              <Select.Label>Rows</Select.Label>
              {#each fruits as option (option.value)}
                <Select.Item value={option.value} label={option.label}>{option.label}</Select.Item>
              {/each}
            </Select.Group>
          </Select.Content>
        </Select.Root>
          <!-- <Select
            value={`${table.getState().pagination.pageSize}`}
            onValueChange={(value) => {
              table.setPageSize(Number(value))
            }}
          >
            <SelectTrigger className="h-8 w-[70px]">
              <SelectValue placeholder={table.getState().pagination.pageSize} />
            </SelectTrigger>
            <SelectContent side="top">
              {[10, 20, 25, 30, 40, 50].map((pageSize) => (
                <SelectItem key={pageSize} value={`${pageSize}`}>
                  {pageSize}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>  -->
  </div>


  <!-- Pagination Controls-->
  <div class="flex items-center justify-end space-x-2 py-4 pt-1 pb-1">
  <Pagination.Root count={totalCount} perPage={pageSize} page={currentPage+1} {siblingCount}>
    {#snippet children({ pages, currentPage })}
      <Pagination.Content>
        <Pagination.Item>
          <Pagination.PrevButton onclick={() => table.previousPage()} class="text-xs"/>
        </Pagination.Item>
        {#each pages as page (page.key)}
          {#if page.type === "ellipsis"}
            <Pagination.Item>
              <Pagination.Ellipsis />
            </Pagination.Item>
          {:else}
            <Pagination.Item>
              <Pagination.Link {page} onclick={() => table.setPageIndex(page.value - 1)} isActive={currentPage === page.value} class="text-xs! w-min pl-2 pr-2 pt-1 pb-1 h-min rounded-sm">
                {page.value}
              </Pagination.Link>
            </Pagination.Item>
          {/if}
        {/each}
        <Pagination.Item>
          <Pagination.NextButton onclick={() => table.nextPage()} class="text-xs"/>
        </Pagination.Item>
      </Pagination.Content>
    {/snippet}
  </Pagination.Root>
  </div>
  </div>
</div>

</div>
