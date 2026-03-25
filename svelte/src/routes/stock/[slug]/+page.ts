import { error } from '@sveltejs/kit';
import type { PageLoad } from './$types';
import { detail  } from '$lib/brapi/v2/germplasm';

export const load: PageLoad = async ({ fetch, params }) => {

    let result = await detail({germplasmDbId: Number(params.slug)});
    if (result.data && result.data.result){
        return {result: result.data.result}
    } else {
	    error(404, 'Not found');
    }

};