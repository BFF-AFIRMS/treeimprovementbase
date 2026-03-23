import type { ColumnDef } from "@tanstack/table-core";
import { renderComponent } from "$lib/components/ui/data-table";
import {type SchemaType} from "$lib/breedbase/organism";

import Actions from "./actions.svelte";
import Button from "$lib/components/ui/button/button.svelte";
import { Checkbox } from "$lib/components/ui/checkbox";
import { createRawSnippet } from "svelte";
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
    accessorKey: "organism_id",
    accessorFn: (row) => { return row.organism_id == null ? '' : row.organism_id},
    header: ({column}) =>
        renderComponent(SortableHeader, {
            name: "ID",
            onclick: column.getToggleSortingHandler(),
        }),
    enableSorting: true,
    enableColumnFilter: true
  },
  {
    id: "Species",
    accessorKey: "species",
    accessorFn: (row) => { return row.species == null ? '' : row.species},
    header: ({column}) =>
        renderComponent(SortableHeader, {
            name: "Species",
            onclick: column.getToggleSortingHandler(),
        }),
    cell: ({row}) =>
    {
      const cellSnippet = createRawSnippet<[]>(() => {
        return { render: () => `<a href="/organism/${row.original.organism_id}/view">${row.original.species}</a>` };
        });
      return renderComponent(Button, { children: cellSnippet, variant: "outline", class: "bg-blue-200 hover:bg-blue-300 pt-0 pb-0 pl-1 pr-1 h-full"})
    },
    enableColumnFilter: true,
  },
  {
    id: "Genus",
    accessorKey: "genus",
    accessorFn: (row) => { return row.genus == null ? '' : row.genus},
    header: ({column}) =>
        renderComponent(SortableHeader, {
            name: "Genus",
            onclick: column.getToggleSortingHandler(),
        }),
    cell: ({row}) => { return row.original.genus;},
    enableColumnFilter: true,
  },
  {
    id: "Abbreviation",
    accessorKey: "abbreviation",
    accessorFn: (row) => { return row.abbreviation == null ? '' : row.abbreviation},
    header: ({column}) =>
        renderComponent(SortableHeader, {
            name: "Abbreviation",
            onclick: column.getToggleSortingHandler(),
        }),
    cell: ({row}) => { return row.original.abbreviation;},
    enableColumnFilter: true,
  },
  {
    id: "Common Name",
    accessorKey: "common_name",
    accessorFn: (row) => { return row.common_name == null ? '' : row.common_name},
    header: ({column}) =>
        renderComponent(SortableHeader, {
            name: "Common Name",
            onclick: column.getToggleSortingHandler(),
        }),
    cell: ({row}) => { return row.original.common_name },
    enableColumnFilter: true,
  },
];

// if (userRole.data && userRole.data.user_role == 'curator'){
//   columns.push(
//     {
//       id: "rowAction",
//       cell: ({ row }) => {
//         return renderComponent(Actions, { project_id: row.original.project_id, name: row.original.name, description: row.original.description });
//       },
//       enableColumnFilter: false,
//     },
//   )
// }
