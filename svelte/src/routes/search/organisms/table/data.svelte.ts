import { organisms } from "$lib/breedbase/organism.js";

export const params = {};
let data = $state(organisms(params));

// Fetch new data for the table
export function fetchData() {
    data = organisms(params);
}

export function getData() {
    return data;
}
