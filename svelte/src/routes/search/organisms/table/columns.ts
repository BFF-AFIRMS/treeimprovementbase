import type { ColumnDef } from "@tanstack/table-core";
import { createRawSnippet } from "svelte";
import { renderComponent, renderSnippet } from "$lib/components/ui/data-table/index.js";
import {type SchemaType} from "$lib/breedbase/organism";

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
    accessorKey: "organism_id",
    header: ({column}) =>
        renderComponent(SortableHeader, {
            name: "ID",
            onclick: column.getToggleSortingHandler(),
        }),
    enableSorting: true,
    enableColumnFilter: true
  },
  {
    id: "Genus",
    accessorKey: "genus",
    header: ({column}) =>
        renderComponent(SortableHeader, {
            name: "Genus",
            onclick: column.getToggleSortingHandler(),
        }),
    cell: ({row}) => { return row.original.genus;},
    enableColumnFilter: true,
  },
  {
    id: "Species",
    accessorKey: "species",
    header: ({column}) =>
        renderComponent(SortableHeader, {
            name: "Species",
            onclick: column.getToggleSortingHandler(),
        }),
    cell: ({row}) => { return row.original.species;},
    enableColumnFilter: true,
  },
  {
    id: "Abbreviation",
    accessorKey: "abbreviation",
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
    header: ({column}) =>
        renderComponent(SortableHeader, {
            name: "Common Name",
            onclick: column.getToggleSortingHandler(),
        }),
    cell: ({row}) => { return row.original.common_name;},
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
