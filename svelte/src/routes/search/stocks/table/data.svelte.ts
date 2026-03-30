import { get as getGermplasm } from "$lib/brapi/v2/germplasm";
let data = $state(getGermplasm({}));

// Fetch new data for the table
export function fetchData() {
    data = getGermplasm({});
}

export function getData() {
    return data;
}
