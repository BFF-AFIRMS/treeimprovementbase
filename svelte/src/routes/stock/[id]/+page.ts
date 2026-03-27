import { error } from '@sveltejs/kit';
import type { PageLoad } from './$types';
import { detail  } from '$lib/brapi/v2/germplasm';

export const prerender = false;

export const load: PageLoad = async ({ params }) => {

    let result = await detail({germplasmDbId: Number(params.id)});
    if (result.data && result.data.result){
        return {result: result.data.result}
    } else {
	    error(404, 'Not found');
    }

};
