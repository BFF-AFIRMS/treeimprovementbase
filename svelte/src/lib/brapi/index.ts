import { PUBLIC_BREEDBASE_URL } from '$env/static/public';
console.log("PUBLIC_BREEDBASE_URL:", PUBLIC_BREEDBASE_URL);
export const brapi_url = PUBLIC_BREEDBASE_URL + "/brapi/v2";
export {Pagination} from './pagination.ts';
export *  as v2 from './v2';
