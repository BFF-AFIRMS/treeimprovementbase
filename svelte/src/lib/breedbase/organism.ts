import { fetchResult, parseErrors, ResultSchema } from './utils';
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

// Required schema to create a new organism
export const CreateSchema = z.object({
    species: z.string({ error: (iss) => iss.input == null ? "Species is a required field." : `Species is invalid: ${iss.input}` }),
    common_name: z.string().nullable().default(null),
    abbreviation: z.string().nullable().default(null),
});
export type CreateType = z.infer<typeof CreateSchema>;


// ----------------------------------------------------------------------------
// Actions

// Create new organism
export async function create({program} : {program: SchemaType}) {

  let result = ResultSchema.parse({});

  // Input validation
  let parsed = CreateSchema.safeParse(program);
  result.error = parseErrors(parsed);
  if (result.error){ return result; }

  // Post data to backend server
  const query = new URLSearchParams(parsed.data).toString();
  result = await fetchResult({
    url: `/ajax/svelte/organism/create?${query}`,
    method: 'GET',
    errorMsg: 'Failed to create organism.',
    successMsg: 'Succeeded in creating organism.'
  });

  return result;

}

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
