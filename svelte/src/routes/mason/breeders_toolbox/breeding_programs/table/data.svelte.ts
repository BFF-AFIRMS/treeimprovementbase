import { programs } from "$lib/brapi/v2";

export const params = {pageSize: 1000000};
let data = $state(programs(params));

// Fetch new data for the table
export function fetchData() {
    data = programs(params);
}

export function getData() {
    return data;
}