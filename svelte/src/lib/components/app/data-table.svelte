<script lang="ts" generics="TData, TValue">
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
    type VisibilityState,
    getCoreRowModel,
    getPaginationRowModel,
    getSortedRowModel,
    getFilteredRowModel,
  } from "@tanstack/table-core";

  import {
    createSvelteTable,
    FlexRender,
  } from "$lib/components/ui/data-table/index.js";

  import { Button } from "$lib/components/ui/button/index.js";
  import * as DropdownMenu from "$lib/components/ui/dropdown-menu/index.js";
  import * as Table from "$lib/components/ui/table/index.js";
  import { Input } from "$lib/components/ui/input/index.js";
  import * as Select from "$lib/components/ui/select/index.js";
  import {Skeleton } from "$lib/components/ui/skeleton/index.js";

  import {exportToCsv, exportToExcel} from "$lib/export-table";


  type DataTableProps<TData, TValue> = {
    columns: ColumnDef<TData, TValue>[];
    data: TData[],
    caption: string,
    totalCount: number,
    pageSize: number,
    currentPage: number,
    skeleton: boolean,
    filePrefix: string,
    tableClass: String,
  };

  let {
    data,
    columns,
    caption,
    totalCount,
    pageSize=10,
    currentPage=0,
    skeleton=false,
    tableClass="",
    filePrefix="table"
  }: DataTableProps<TData, TValue> = $props();

  // if (skeleton == true) {
  //   columns.forEach(function (column, i){
  //     columns[i].cell = () => {
  //       return renderComponent(Skeleton, {class: "h-[20px] w-full rounded-sm bg-gray-200"});
  //     };
  //     data = [{}];
  //   })
  // }

  let pagination = $derived<PaginationState>({ pageIndex: currentPage, pageSize: pageSize });

  let sorting = $state<SortingState>([]);
  let columnFilters = $state<ColumnFiltersState>([]);
  let columnVisibility = $state<VisibilityState>({});
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
      get columnFilters()    { return columnFilters; },
      get columnVisibility() { return columnVisibility},
      get pagination()       { return pagination; },
      get rowSelection()     { return rowSelection; },
      get sorting()          { return sorting; },
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
    onColumnVisibilityChange: (updater) => {
      if (typeof updater === "function") {
        columnVisibility = updater(columnVisibility);
      } else {
        columnVisibility = updater;
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

  const rowsPerPageOptions = [
    { value: 1, label: "1" },
    { value: 5, label: "5" },
    { value: 10, label: "10" },
    { value: 100, label: "100" },
    { value: 1000, label: "1000" },
    { value: 10000, label: "10000" },
  ];

</script>

<div class="h-full">
  <div class="rounded-md border shadow-sm p-2 h-full {tableClass}">

    <div class="flex items-center py-2">

      <!-- Column Visibility -->
      <DropdownMenu.Root>
        <DropdownMenu.Trigger>
          {#snippet child({ props })}
            <Button {...props} variant="outline" class="ms-auto ml-2">Columns</Button>
          {/snippet}
        </DropdownMenu.Trigger>
        <DropdownMenu.Content align="end">
          {#each table
            .getAllColumns()
            .filter((col) => col.getCanHide()) as column (column.id)}
            <DropdownMenu.CheckboxItem
              bind:checked={
                () => column.getIsVisible(), (v) => column.toggleVisibility(!!v)
              }
            >
              {column.id}
            </DropdownMenu.CheckboxItem>
          {/each}
        </DropdownMenu.Content>
      </DropdownMenu.Root>

      <Button class="ml-2" onclick={() => exportToCsv(table, ",", filePrefix + ".csv")}>Export To CSV</Button>
      <Button class="ml-2" onclick={() => exportToExcel(table, filePrefix + ".xlsx")}>Export To Excel</Button>
    </div>

    <!-- Table-->
    <Table.Root>
        <Table.Caption class="text-xs pt-4 pb-0 sticky bottom-0 bg-white z-1">{caption}</Table.Caption>
        <Table.Header class="sticky top-0 bg-white z-1">
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
                  <Table.Cell class="p-1">
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

  <!-- Footer -->
  <div class="flex items-center justify-between px-2">

    <!-- Summarize Selected -->
    <div class="text-muted-foreground flex-1 text-xs text-left">
      {table.getFilteredSelectedRowModel().rows.length} of{" "}
      {table.getFilteredRowModel().rows.length} row(s) selected.
    </div>

    <!-- Rows Per Page -->
    <div class="flex items-center space-x-6 lg:space-x-4">
      <div class="flex items-center space-x-2">
        <span class="text-muted-foreground text-xs">Rows per page</span>
        <Select.Root
          type="single"
          name="rowsPerPage"
          bind:value={
          () => String(table.getState().pagination.pageSize),
          (v) => table.setPageSize(Number(v))
        }>
          <Select.Trigger class="w-[180px]">
            {table.getState().pagination.pageSize}
          </Select.Trigger>
          <Select.Content>
            <Select.Group>
              <Select.Label>Rows</Select.Label>
              {#each rowsPerPageOptions as option (option.value)}
                <Select.Item value={String(option.value)} label={option.label}>{option.label}</Select.Item>
              {/each}
            </Select.Group>
          </Select.Content>
        </Select.Root>
      </div>


    <!-- Pagination Controls-->
      <div class="flex items-center justify-end space-x-2 py-4 pt-1 pb-1">
      <Pagination.Root count={totalCount} perPage={table.getState().pagination.pageSize} page={currentPage+1} {siblingCount}>
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
