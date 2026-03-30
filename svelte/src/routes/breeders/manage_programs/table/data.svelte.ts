import { get as getBreedingPrograms } from "$lib/brapi/v2/programs";

let data = $state(getBreedingPrograms({}));

// Fetch new data for the table
export function fetchData() {
    data = getBreedingPrograms({});
}

export function getData() {
    return data;
}
