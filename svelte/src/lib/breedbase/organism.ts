import { fetchResult } from './utils';
import { z } from 'zod';

// ----------------------------------------------------------------------------
// Schemas

// Organism schema
export const Schema = z.object({
    organism_id: z.coerce.number().int().nullable().default(null),
    common_name: z.string().nullable().default(null),
    genus: z.string().nullable().default(null),
    species: z.string().nullable().default(null),
    abbreviation: z.string().nullable().default(null),
}).default({});
export type SchemaType = z.infer<typeof Schema>;

// ----------------------------------------------------------------------------
// Actions

// Get all organisms
export async function get() {

  // Post data to backend server
  let result = await fetchResult({
    url: `/ajax/svelte/organisms`,
    method: 'GET',
    errorMsg: 'Failed to fetch organisms.',
    successMsg: 'Succeeded in fetching organisms.'
  });

  if (result.data && result.data.organisms){
    result.data = result.data.organisms.map((record: Object) => Schema.parse(record))
  }
  return result;
}
