import * as z from "zod";
import { error } from '@sveltejs/kit';
import { brapi_url } from "../index.ts";

// This type is used to define the shape of our data.
export const ProgramSchema = z.object({
    abbreviation: z.string().nullable() || '',
    additionalInfo: z.object({
        description: z.string().nullable().optional() || '',
    }).nullable(),
    objective: z.string().nullable(),
    programDbId:  z.string(),
    programName:  z.string(),
});

export type ProgramType = z.infer<typeof ProgramSchema>;


/** `GET /programs`
 * @param  {Object} params Parameters to provide to the call
 * @return {ProgramSchema[]}
 */
export async function programs (params?: Object){
    let url = `${brapi_url}/programs`;
    if (params){
      let query = new URLSearchParams(params).toString();
      url += `?${query}`;
    }

    // Testing awaiting promises
    // await new Promise(r => setTimeout(r, 2000));

    const response: Response = await fetch(url);
    const result = await response.json();
    let data = result.result.data;

    if (data.length > 0) {
      result.result.data = data.map((record: Object) => ProgramSchema.parse(record))
    } else {
      result.result.data = [];
    }
    return result
}

/** `GET /programs/{programDbId}`
 * @param  {Object} params Parameters to provide to the call
 * @param  {String} programDbId programDbId
 * @return {ProgramSchema}
 */
export async function programs_detail (programDbId: Number, params?: Object){
    let url = `${brapi_url}/programs/${programDbId}`;
    if (params){
      let query = new URLSearchParams(params).toString();
      url += `?${query}`;
    }

    const response: Response = await fetch(url);
    const data = await response.json();
    const pagination = data.metadata.pagination;
    if (Object.keys(data.result).length > 0) {
      return ProgramSchema.parse(data.result);
    } else {
      error(404, { message: 'Not found' });
    }
}
