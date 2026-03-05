// Inspired by: https://github.com/grvctr/tanstack-table-export-to-csv

import {type Cell, type Header, type Row, type RowData} from "@tanstack/table-core";

export const exportToCsv = (table, delim:string = ",", fileName: string = "file.csv") => {

    // Extract the headers and rows
    const headers = table
        .getHeaderGroups()
        .map((group) => group.headers)
        .flat()
        .map((header: Header<RowData, string>) => header.id);

    // Remove the rowSelect checkbox column
    let rowSelectIndex = headers.findIndex((h:string) => h === "rowSelect");
    headers.splice(rowSelectIndex, 1);
    let rowActionIndex = headers.findIndex((h:string) => h === "rowAction");
    headers.splice(rowActionIndex, 1);

    const rows = table
        .getFilteredRowModel()
        .rows
        .filter((row: Row<RowData>) => row.getIsSelected())
        .map((row: Row<RowData>) => {
            return row
                .getAllCells()
                .filter((_cell, i) => i != rowSelectIndex && i != rowActionIndex)
                .map((cell) => cell.getValue() ? cell.getValue() : "NA" )
    });

    // Raise error if no rows were selected
    if ( rows.length == 0 ){
        alert("Please select the rows you would like to download.");
        return;
    }

    // Convert to CSV blob
    let csv = headers.join(delim) + "\n";
    rows.forEach((row: Array<string>) => { csv += row.join(delim) + "\n"; });
    let blob = new Blob([csv], { type: "text/csv" });

    // Download blob as file
    var a = document.createElement('a');
    document.body.append(a);
    a.download = fileName;
    a.href = URL.createObjectURL(blob);
    a.click();
    a.remove();
}
