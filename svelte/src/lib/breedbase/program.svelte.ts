import { PUBLIC_BREEDBASE_URL } from '$env/static/public';
import { z } from 'zod';

// Program submission schema
export const ProgramSchema = z.object({
    id: z.coerce.number().int().nullable().default(null),
    name: z.string().nullable().default(null),
    desc: z.string().nullable().default(null),
}).default({});
export type ProgramType = z.infer<typeof ProgramSchema>;

// Generic return type for functions in this module
export const ProgramResultSchema = z.object({
    error: z.string().nullable().default(null),
    success: z.string().nullable().default(null),
}).default({});
export type ProgramResultType = z.infer<typeof ProgramResultSchema>;


// Required schema to delete a breeding program
export const DeleteProgramValidator = z.object({
    id: z.coerce.number({ error: (iss) => iss.input == null ? "ID is a required field." : "ID is invalid." }).int(),
});

// Required schema to edit a breeding program
export const EditProgramValidator = z.object({
    id: z.coerce.number({ error: (iss) => iss.input == null ? "ID is a required field." : "ID is invalid." }).int(),
    name: z.string({ error: (iss) => iss.input == null ? "Name is a required field." : "Name is invalid." }),
    desc: z.string({ error: (iss) => iss.input == null ? "Description is a required field." : "Description is invalid." })
});

// Required schema to create a new breeding program
export const CreateProgramValidator = z.object({
    name: z.string({ error: (iss) => iss.input == null ? "Name is a required field." : "Name is invalid." }),
    desc: z.string({ error: (iss) => iss.input == null ? "Description is a required field." : "Description is invalid." })
});

// Delete breeding program from the database.
export async function deleteProgram({program} : {program: ProgramType}) {

  let result = ProgramResultSchema.parse({});

  // Input validation
  let parsed = DeleteProgramValidator.safeParse(program);
  if (!parsed.success) {
    let errorMessages: string[] = [];
    parsed.error.issues.forEach((issue) => {
      errorMessages.push(issue.message);
    })
    result.error = errorMessages.join(" ");
    return result;
  }

  // Post data to backend server
  let url = `${PUBLIC_BREEDBASE_URL}/breeders/program/delete/${parsed.data.id}`;
  return await postData({url: url, result: result, verb: 'delete'});
}

// Edit a breeding program details
export async function editProgram({program} : {program: ProgramType}) {

  let result = ProgramResultSchema.parse({});

  // Input validation
  let parsed = EditProgramValidator.safeParse(program);
  if (!parsed.success) {
    let errorMessages: string[] = [];
    parsed.error.issues.forEach((issue) => {
      errorMessages.push(issue.message);
    })
    result.error = errorMessages.join(" ");
    return result;
  }

  // Post data to backend server
  const query = new URLSearchParams(parsed.data).toString();
  let url = `${PUBLIC_BREEDBASE_URL}/breeders/program/store?${query}`;
  result = await postData({url: url, result: result, verb: 'edit'});
  return result;
}


// Create a new breeding program
export async function createProgram({program} : {program: ProgramType}) {

  let result = ProgramResultSchema.parse({});

  // Input validation
  let parsed = CreateProgramValidator.safeParse(program);
  if (!parsed.success) {
    let errorMessages: string[] = [];
    parsed.error.issues.forEach((issue) => {
      errorMessages.push(issue.message);
    })
    result.error = errorMessages.join(" ");
    return result;
  }

  // Post data to backend server
  const query = new URLSearchParams(parsed.data).toString();
  let url = `${PUBLIC_BREEDBASE_URL}/breeders/program/store?${query}`;
  return await postData({url: url, result: result, verb: 'upload'});
}

async function postData({ url, result, verb }: {url: string, result: ProgramResultType, verb: string}) {
  let response: Response;
  try {
    response = await fetch(url, {method: 'POST'});
  } catch(error) {
    result.error = error.message;
    return result;
  }

  if (!response.ok){
    result.error = `Failed to ${verb} the breeding program. ${response.statusText} (${response.status}).`
  } else {
    // Check if we have an error message
    let data = await response.json();
    if (data.error) {
      result.error = `Failed to ${verb} the breeding program. ${data.error}`
    } else {
      result.success = `The breeding program ${verb} was successful.`;
    }
  }

  return result;
}
