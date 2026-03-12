import { fetchResult } from './utils';
import { z } from 'zod';

// Generic return type for functions in this module
export const Role = z.object({
    user_role: z.string(),
});
export type RoleType = z.infer<typeof Role>;


export async function getRole() {

  // Post data to backend server
  let result = fetchResult({
    url: `/ajax/user/role`,
    method: 'GET',
    errorMsg: 'Failed to fetch user roles.',
    successMsg: 'Succeeded to fetch user roles.'
  });
  return result;
}
