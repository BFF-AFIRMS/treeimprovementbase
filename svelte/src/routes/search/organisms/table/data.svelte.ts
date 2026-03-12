import { get as getOrganisms } from "$lib/breedbase/organism";
let data = $state(getOrganisms());

// Fetch new data for the table
export function fetchData() {
    data = getOrganisms();
}

export function getData() {
    return data;
}
