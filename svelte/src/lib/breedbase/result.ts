import { PUBLIC_BREEDBASE_URL } from '$env/static/public';
import { z } from 'zod';

// Generic return type for functions in this module
export const ResultSchema = z.object({
    error: z.string().nullable().default(null),
    success: z.string().nullable().default(null),
    data: z.object().nullable().default({}),
}).default({});
export type ResultType = z.infer<typeof ResultSchema>;

export async function fetchResult({ url, method, errorMsg, successMsg }: {url: string, method: string, errorMsg: string, successMsg: string}) {

    let result = ResultSchema.parse({});

    let response: Response;
    try {
        response = await fetch(`${PUBLIC_BREEDBASE_URL}${url}`, {method: method});
    } catch(error) {
        result.error = error.message;
        return result;
    }

    if (!response.ok){
        result.error = `${errorMsg} ${response.statusText} (${response.status}).`
    } else {
        // Check if we have an error message
        result.data = await response.json();
        if (result.data.error) {
        result.error = `${errorMsg} ${result.data.error}`
        } else {
        result.success = `${successMsg}`;
        }
    }

  return result;
}
