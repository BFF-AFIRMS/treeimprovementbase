// Inspired by: https://github.com/grvctr/tanstack-table-export-to-csv

import {type Header, type Row, type RowData} from "@tanstack/table-core";
import * as XLSX from "xlsx";

export const downloadBlob = (blob: Blob, fileName: string) => {
    // Download blob as file
    var a = document.createElement('a');
    document.body.append(a);
    a.download = fileName;
    a.href = URL.createObjectURL(blob);
    a.click();
    a.remove();

}

export const exportToCsv = (
    table,
    delim:string = ",",
    fileName: string = "file.csv"
    ) => {

    let csv = tableToCsv(table, delim);

    if (csv) {
        let blob = new Blob([csv], { type: "text/csv" });
        downloadBlob(blob, fileName);
    }
}


export const tableToCsv = (table, delim:string = ",") => {

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
                .map((cell) => cell.getValue() ? '"' + cell.getValue() + '"' : '"NA"' )
    });

    // Raise error if no rows were selected
    if ( rows.length == 0 ){
        alert("Please select the rows you would like to download.");
        return;
    }

    // Convert to CSV blob
    let csv = headers.join(delim) + "\n";
    rows.forEach((row: Array<string>) => { csv += row.join(delim) + "\n"; });
    return csv;
}

export const exportToExcel = (table, fileName: string = "file.xlsx") => {
    let csv = tableToCsv(table)

    if (csv) {
        let workbook = XLSX.read(csv, { type: "string" });
        XLSX.writeFile(workbook,fileName);
    }
}
