import type { ColumnDef } from "@tanstack/table-core";
import { renderComponent } from "$lib/components/ui/data-table";
import {type SchemaType} from "$lib/brapi/v2/germplasm";
import { Checkbox } from "$lib/components/ui/checkbox";
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
    accessorKey: "germplasmDbId",
    accessorFn: (row) => { return row.germplasmDbId == null ? '' : row.germplasmDbId},
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
    accessorKey: "Name",
    accessorFn: (row) => { return row.germplasmName == null ? '' : row.germplasmName},
    header: ({column}) =>
        renderComponent(SortableHeader, {
            name: "Name",
            onclick: column.getToggleSortingHandler(),
        }),
    cell: ({row}) => { return row.original.germplasmName;},
    enableColumnFilter: true,
  },
  {
    id: "Species",
    accessorKey: "Species",
    accessorFn: (row) => { return row.species == null ? '' : row.species},
    header: ({column}) =>
        renderComponent(SortableHeader, {
            name: "Species",
            onclick: column.getToggleSortingHandler(),
        }),
    cell: ({row}) => { return row.original.species;},
    enableColumnFilter: true,
  },
]
