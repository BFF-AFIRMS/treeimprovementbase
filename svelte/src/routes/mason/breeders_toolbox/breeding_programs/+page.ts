import {programs} from "$lib/brapi/v2";
import type { PageLoad } from './$types';

export const load: PageLoad = ({ url }) => {
    let params = {pageSize: 1000000};
    //url.searchParams.set("pageSize", "1000000")
    let promise = programs(params);
    return {"promise": promise}
};
