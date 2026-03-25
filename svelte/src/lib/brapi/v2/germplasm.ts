import * as z from "zod";
import { brapi_url } from "../index.ts";
import { fetchResult } from "../utils.ts";

// This type is used to define the shape of our data.
export const Schema = z.object({
    accessionNumber: z.string(),
    acquisitionDate: z.coerce.date(),
    additionalInfo: z.string().nullable(),
    biologicalStatusOfAccessionCode: z.number(),
    biologicalStatusOfAccessionDescription: z.string().nullable(),
    breedingMethodDbId: z.string().nullable(),
    collection: z.string().nullable(),
    commonCropName: z.string(),
    countryOfOriginCode: z.string(),
    defaultDisplayName: z.string(),
    documentationURL: z.string(),
    // donors
    // externalReferences
    genus: z.string(),
    germplasmDbId: z.coerce.number(),
    germplasmName: z.string(),
    // germplasmOrigin
    germplasmPUI: z.string(),
    germplasmPreprocessing: z.string().nullable(),
    instituteCode: z.string(),
    instituteName: z.string(),
    pedigree: z.string(),
    seedSource: z.string(),
    seedSourceDescription: z.string(),
    species: z.string(),
    speciesAuthority: z.string().nullable(),
    // storageTypes: 
    subtaxa: z.string().nullable(),
    subtaxaAuthority: z.string().nullable(),
    // synonyms: 
    // taxonIds
});

export type SchemaType = z.infer<typeof Schema>;

/** `GET /programs/{programDbId}`
 * @param  {Object} params Parameters to provide to the call
 * @param  {String} germplasmDbId programDbId
 * @return {Schema}
 */

export async function detail({germplasmDbId, params} : {germplasmDbId: Number, params?: Object}) {
    let url = `/germplasm/${germplasmDbId}`;
    if (params){
      let query = new URLSearchParams(params).toString();
      url += `?${query}`;
    }

    let result = await fetchResult({
        url: url,
        method: 'GET',
        errorMsg: 'Failed to fetch germplasm detail.',
        successMsg: 'Succeeded in fetching germplasm detail.'
    });

  if (result.data && result.data.result){
    result.data.result = Schema.parse(result.data.result);
  }

  return result;
    
}