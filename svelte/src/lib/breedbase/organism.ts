import { getCookies } from "$lib/cookies/cookies.js";
import { PUBLIC_BREEDBASE_URL } from '$env/static/public';
import { z } from 'zod';

// Organism schema
export const OrganismSchema = z.object({
    organism_id: z.coerce.number().int().nullable().default(null),
    common_name: z.string().nullable().default(null),
    genus: z.string().nullable().default(null),
    species: z.string().nullable().default(null),
    abbreviation: z.string().nullable().default(null),
}).default({});
export type OrganismType = z.infer<typeof OrganismSchema>;


export async function organisms (params?: Object){

    let error: string | null = null;
    let result = { result: {data: [], error: error } };

    let url = `${PUBLIC_BREEDBASE_URL}/ajax/search/organism`;
    if (params){
      let query = new URLSearchParams(params).toString();
      url += `?${query}`;
    }

    let cookies = getCookies();
    let headers : Record<string, string> = {};
    if ('sgn_session_id' in cookies){
      headers['Authorization'] = `Bearer ${cookies.sgn_session_id}`;
    }

    // Testing awaiting promises
    // await new Promise(r => setTimeout(r, 2000));

    let response: Response;

    try {
      response = await fetch(url, {headers: headers});
    } catch(error) {
      // TBD: Get error.cause to pass along correctly;
      result.result.error = error.message;
      return result;
    }


    // If fetch failed, return with error
    if (response.status != 200){
      result.result.error = `${response.statusText} (${response.status})`;
      return result
    }

    result = await response.json();

    // Otherwise, parse the data
    let data = result.result.data;
    if (data.length > 0) {
      result.result.data = data.map((record: Object) => OrganismSchema.parse(record))
    } else {
      result.result.data = [];
    }
    return result
}
