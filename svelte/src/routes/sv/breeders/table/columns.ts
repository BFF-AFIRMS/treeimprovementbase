import type { ColumnDef } from "@tanstack/table-core";
import { createRawSnippet } from "svelte";
import { renderComponent, renderSnippet } from "$lib/components/ui/data-table/index.js";
import {type ProgramType} from "$lib/brapi/v2";

import Actions from "./actions.svelte";
import { Checkbox } from "$lib/components/ui/checkbox/index.js";
import SortableHeader from "./sortable.svelte";

export const columns: ColumnDef<ProgramType>[] = [
  {
    id: "rowSelect",
    header: ({ table }) =>
      renderComponent(Checkbox, {
        checked: table.getIsAllPageRowsSelected(),
        indeterminate:
          table.getIsSomePageRowsSelected() &&
          !table.getIsAllPageRowsSelected(),
        onCheckedChange: (value) => table.toggleAllPageRowsSelected(!!value),
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
    id: "Objective",
    accessorKey: "objective",
    header: ({column}) =>
        renderComponent(SortableHeader, {
            name: "Objective",
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
  {
    id: "Abbreviation",
    accessorKey: "abbreviation",
    // header: () => {
    //   return renderSnippet(
    //     createRawSnippet(() => ({
    //       render: () => `<div class="text-center">Abbreviation</div>`,
    //     })
    //   ));
    // },
    header: ({column}) =>
        renderComponent(SortableHeader, {
            name: "Abbreviation",
            onclick: column.getToggleSortingHandler(),
        }),
    enableColumnFilter: true,
    enableSorting: true,
  },
  // {
  //   accessorKey: "description",
  //   header: "Description",
  //   cell: ({ row }) => { return row.original.additionalInfo.description }
  // },
  {
    id: "rowAction",
    cell: ({ row }) => {
      // You can pass whatever you need from `row.original` to the component
      return renderComponent(Actions, { name: row.original.programName });
    },
    enableColumnFilter: false,
  },
];
