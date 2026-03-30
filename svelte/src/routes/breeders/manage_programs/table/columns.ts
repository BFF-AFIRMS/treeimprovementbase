import type { ColumnDef } from "@tanstack/table-core";
import { createRawSnippet } from "svelte";
import { renderComponent, renderSnippet } from "$lib/components/ui/data-table/index.js";
import {type SchemaType} from "$lib/brapi/v2/programs";

import Actions from "./actions.svelte";
import { Checkbox } from "$lib/components/ui/checkbox/index.js";
import SortableHeader from "$lib/components/app/sortable-header.svelte";
import { User } from "$lib/breedbase";

let userRole = await User.getRole();

export var columns: ColumnDef<SchemaType>[] = [
  {
    id: "rowSelect",
    header: ({ table }) =>
      renderComponent(Checkbox, {
        checked: table.getIsAllRowsSelected(),
        indeterminate:
          table.getIsSomeRowsSelected() &&
          !table.getIsAllRowsSelected(),
        onCheckedChange: (value) => table.toggleAllRowsSelected(!!value),
        "aria-label": "Select all",
      }),
    cell: ({ row }) =>
      renderComponent(Checkbox, {
        checked: row.getIsSelected(),
        onCheckedChange: (value) => row.toggleSelected(!!value),
        "aria-label": "Select row",
      }),
    enableSorting: false,
    enableHiding: false,
  },
  {
    id: "ID",
    accessorKey: "programDbId",
    accessorFn: (row) => { return row.programDbId == null ? '' : row.programDbId},
    header: ({column}) =>
        renderComponent(SortableHeader, {
            name: "ID",
            onclick: column.getToggleSortingHandler(),
        }),
    enableSorting: true,
    enableColumnFilter: true
  },
  {
    id: "Name",
    accessorKey: "programName",
    accessorFn: (row) => { return row.programName == null ? '' : row.programName},
    header: ({column}) =>
        renderComponent(SortableHeader, {
            name: "Name",
            onclick: column.getToggleSortingHandler(),
        }),
    cell: ({row}) => {
      const cellSnippet = createRawSnippet<[string]>(() => {
        return {
          render: () => `<div class="font-medium">${row.original.programName}</div>`,
        };
        });
      return renderSnippet(cellSnippet);
    },
    enableColumnFilter: true,
  },
  {
    id: "Description",
    accessorKey: "objective",
    accessorFn: (row) => { return row.objective == null ? '' : row.objective},
    header: ({column}) =>
        renderComponent(SortableHeader, {
            name: "Description",
            onclick: column.getToggleSortingHandler(),
        }),
    cell: ({row}) => {
      const cellSnippet = createRawSnippet<[string]>(() => {
        return {
          render: () => `<div class="text-left whitespace-normal sm:max-w-sm md:max-w-md lg:max-w-lg xl:max-w-full">${row.original.objective}</div>`,
        };
        });
      return renderSnippet(cellSnippet);
    },
    enableColumnFilter: true,
    enableSorting: true,
  },
];

if (userRole.data && userRole.data.user_role == 'curator'){
  columns.push(
    {
      id: "rowAction",
      cell: ({ row }) => {
        return renderComponent(Actions, {
          programDbId: row.original.programDbId,
          programName: row.original.programName,
          objective: row.original.objective,
      });
      },
      enableColumnFilter: false,
    },
  )
}
