import type { PageLoad } from './$types';
import { User } from "$lib/breedbase";

export const load: PageLoad = async ({ params }) => {
  let result = await User.getRole();
  return result.data;
};
