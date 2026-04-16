<script lang="ts">

    import * as Accordion from "$lib/components/ui/accordion";
    import Button from '$lib/components/ui/button/button.svelte';
    import { search as attributeValuesSearch } from '$lib/brapi/v2/germplasmAttributeValues';
    import { detail  } from '$lib/brapi/v2/germplasm';
    import {type ResultType} from '$lib/brapi/utils';
    import { Input } from "$lib/components/ui/input";
    import { onMount } from 'svelte';
    import { resolve } from '$app/paths';
    import { page } from '$app/state';
    import * as Table from "$lib/components/ui/table";

    // let disabled = $state(true);

    // let result = $state();
    // let attributes = $state();
    // let mounted = $state(false);

    // // Fetch data on mount
    // onMount(async () => {
    //     let id = page.url.searchParams.get('id');
    //     if (id == null ){
    //         window.location.replace(resolve('/error/404'));
    //     } else {
    //         result = detail({germplasmDbId: Number(id)});
    //         attributes = attributeValuesSearch({germplasmDbId: Number(id)});
    //         mounted = true;
    //     }
	// });

</script>

<!-- {#if mounted}

    {#await result}
    {:then response}
        {#if (response.data)}
            {$inspect(response.data.result)}
            <h1>{response.data.result.germplasmName}</h1>
            <div class="well">

                <Accordion.Root type="single" class="shadow-none border-0" value="item-1">
                    <Accordion.Item value="item-1">
                        <Accordion.Trigger class="shadow-none border-0 p-0">
                            <div>
                                <span class="text-lg">Overview</span>
                                <br/>
                                <span class="font-normal text-base">View and edit general information about the stock.</span>
                            </div>
                        </Accordion.Trigger>
                        <Accordion.Content>
                            <div class="well-inner">

                                <div class="w-[50%]">

                                <Button class="float-left" variant="outline" onclick={() => {disabled=false}}>Edit</Button>
                                {#if !disabled}
                                    <Button class="float-left ml-4" onclick={() => {disabled=true}}>Submit</Button>
                                {/if}
                                <form>
                                <Table.Root class="mt-4  border-1 p-4">
                                    <Table.Body>
                                        <Table.Row>
                                            <Table.Cell class="font-medium">Organism:</Table.Cell>
                                            <Table.Cell><Input type="text" value={response.data.result.species} disabled={disabled}/></Table.Cell>
                                        </Table.Row>
                                        <Table.Row>
                                            <Table.Cell class="font-medium">Type:</Table.Cell>
                                            <Table.Cell><Input type="text"/></Table.Cell>
                                        </Table.Row>
                                        <Table.Row>
                                            <Table.Cell class="font-medium">Uniquename:</Table.Cell>
                                            <Table.Cell><Input type="text" value={response.data.result.germplasmName} disabled={disabled}/></Table.Cell>
                                        </Table.Row>
                                        <Table.Row>
                                            <Table.Cell class="font-medium">Description:</Table.Cell>
                                            <Table.Cell><Input type="text" disabled={disabled}/></Table.Cell>
                                        </Table.Row>
                                    </Table.Body>
                                </Table.Root>
                                </form>
                                </div>
                            </div>
                        </Accordion.Content>
                    </Accordion.Item>
                </Accordion.Root>


            </div>
        {/if}
    {:catch error}
    Error {error}
    {/await}
{:else}
   <p>Not mounted</p>
{/if} -->
