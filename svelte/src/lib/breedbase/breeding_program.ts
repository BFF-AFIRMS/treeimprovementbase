import { fetchResult, parseErrors, ResultSchema } from './utils';
import { z } from 'zod';

// ----------------------------------------------------------------------------
// Schemas

// Breeding Program schema
export const Schema = z.object({
    project_id: z.coerce.number().int().nullable().default(null),
    name: z.string().nullable().default(null),
    description: z.string().nullable().default(null),
}).default({});
export type SchemaType = z.infer<typeof Schema>;

// Required schema to create a new breeding program
export const CreateSchema = z.object({
    name: z.string({ error: (iss) => iss.input == null ? "Name is a required field." : `Name is invalid: ${iss.input}` }),
    description: z.string(
        { error: (iss) => iss.input == null ? "Description is a required field." : `Description is invalid: ${iss.input}` }
    ),
}).transform(({ description, ...rest }) => ({desc: description, ...rest}));
export type CreateType = z.infer<typeof CreateSchema>;

// Required schema to remove a breeding program
export const RemoveSchema = z.object({
    project_id: z.coerce.number({ error: (iss) => iss.input == null ? "Project ID is a required field." : `Project ID is invalid: ${iss.input}` }).int(),
}).transform(({ project_id, ...rest }) => ({id: project_id, ...rest}));;
export type RemoveType = z.infer<typeof RemoveSchema>;

// Required schema to edit a breeding program
export const EditSchema = z.object({
    project_id: z.coerce.number({ error: (iss) => iss.input == null ? "Project ID is a required field." : `Project ID is invalid: ${iss.input}` }).int(),
    name: z.string({ error: (iss) => iss.input == null ? "Name is a required field." : `Name is invalid: ${iss.input}` }),
    description: z.string({ error: (iss) => iss.input == null ? "Description is a required field." : `Description is invalid: ${iss.input}` }),
}).transform(({ description, project_id, ...rest }) => ({desc: description, id: project_id, ...rest}));
export type EditType = z.infer<typeof EditSchema>;

// ----------------------------------------------------------------------------
// Actions

// Create new breeding program
export async function create({program} : {program: SchemaType}) {

  let result = ResultSchema.parse({});

  // Input validation
  let parsed = CreateSchema.safeParse(program);
  result.error = parseErrors(parsed);
  if (result.error){ return result; }

  // Remove null values
  Object.keys(parsed.data).forEach((key:string)=>{
    if (parsed.data[key] == null){
      delete parsed.data[key];
    }
  });

  // Post data to backend server
  const query = new URLSearchParams(parsed.data).toString();
  result = await fetchResult({
    url: `/breeders/program/store?${query}`,
    method: 'GET',
    errorMsg: 'Failed to create breeding program.',
    successMsg: 'Succeeded in creating breeding program.'
  });

  return result;

}

// Edit a breeding program details
export async function edit({program} : {program: SchemaType}) {

  let result = ResultSchema.parse({});

  // Input validation
  let parsed = EditSchema.safeParse(program);
  result.error = parseErrors(parsed);
  if (result.error){ return result; }
  if (!parsed.data){
    result.error = "No breeding program data was given.";
    return result;
  }

  // Post data to backend server
  const query = new URLSearchParams(parsed.data).toString();
  result = await fetchResult({
    url: `/breeders/program/store?${query}`,
    method: 'GET',
    errorMsg: 'Failed to edit breeding program.',
    successMsg: 'Succeeded in editing breeding program.'
  });

  return result;
}


// Get all breeding programs
export async function get() {

  // Post data to backend server
  let result = await fetchResult({
    url: `/ajax/svelte/breeding_programs`,
    method: 'GET',
    errorMsg: 'Failed to fetch breeding programs.',
    successMsg: 'Succeeded to fetch breeding programs.'
  });

  // Testing awaiting promises
  // await new Promise(r => setTimeout(r, 2000));

  if (result.data && result.data.breeding_programs){
    result.data = result.data.breeding_programs.map((record: Object) => Schema.parse(record))
  }
  return result;
}


// Remove breeding program
export async function remove({program} : {program: SchemaType}) {

  let result = ResultSchema.parse({});

  // Input validation
  let parsed = RemoveSchema.safeParse(program);
  result.error = parseErrors(parsed);
  if (result.error){ return result; }
  if (!parsed.data.project_id){
    result.error = "No breeding program ID was given.";
    return result;
  }

  // Post data to backend server
  result = await fetchResult({
    url: `/breeders/program/delete/${parsed.data.project_id}`,
    method: 'GET',
    errorMsg: 'Failed to delete breeding program.',
    successMsg: 'Succeeded in deleting breeding program.'
  });

  return result;

}
