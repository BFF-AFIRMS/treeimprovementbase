import type { ColumnDef } from "@tanstack/table-core";
import { createRawSnippet } from "svelte";
import { renderComponent, renderSnippet } from "$lib/components/ui/data-table/index.js";
import {type BreedingProgramType} from "$lib/breedbase/breeding_program";

import Actions from "./actions.svelte";
import { Checkbox } from "$lib/components/ui/checkbox/index.js";
import SortableHeader from "./sortable.svelte";
import { User } from "$lib/breedbase";

let userRole = await User.getRole();

export var columns: ColumnDef<BreedingProgramType>[] = [
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
    accessorKey: "project_id",
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
    accessorKey: "name",
    header: ({column}) =>
        renderComponent(SortableHeader, {
            name: "Name",
            onclick: column.getToggleSortingHandler(),
        }),
    cell: ({row}) => {
      const cellSnippet = createRawSnippet<[string]>(() => {
        return {
          render: () => `<div class="font-medium">${row.original.name}</div>`,
        };
        });
      return renderSnippet(cellSnippet);
    },
    enableColumnFilter: true,
  },
  {
    id: "Description",
    accessorKey: "description",
    header: ({column}) =>
        renderComponent(SortableHeader, {
            name: "Description",
            onclick: column.getToggleSortingHandler(),
        }),
    cell: ({row}) => {
      const cellSnippet = createRawSnippet<[string]>(() => {
        return {
          render: () => `<div class="text-left whitespace-normal sm:max-w-sm md:max-w-md lg:max-w-lg xl:max-w-full">${row.original.description}</div>`,
        };
        });
      return renderSnippet(cellSnippet);
    },
    enableColumnFilter: true,
    enableSorting: true,
  },
  // {
  //   id: "Abbreviation",
  //   accessorKey: "abbreviation",
  //   // header: () => {
  //   //   return renderSnippet(
  //   //     createRawSnippet(() => ({
  //   //       render: () => `<div class="text-center">Abbreviation</div>`,
  //   //     })
  //   //   ));
  //   // },
  //   header: ({column}) =>
  //       renderComponent(SortableHeader, {
  //           name: "Abbreviation",
  //           onclick: column.getToggleSortingHandler(),
  //       }),
  //   enableColumnFilter: true,
  //   enableSorting: true,
  // }
];

if (userRole.data.user_role == 'curator'){
  columns.push(
    {
      id: "rowAction",
      cell: ({ row }) => {
        return renderComponent(Actions, { project_id: row.original.project_id, name: row.original.name, description: row.original.description });
      },
      enableColumnFilter: false,
    },
  )
}
