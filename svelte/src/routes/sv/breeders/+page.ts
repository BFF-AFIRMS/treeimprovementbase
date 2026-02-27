import {programs} from "$lib/brapi/v2";
import type { PageLoad } from './$types';

export const load: PageLoad = ({ url }) => {
    url.searchParams.set("pageSize", "1000000"); 
    let promise = programs(url.searchParams);
    return {"promise": promise}
};
