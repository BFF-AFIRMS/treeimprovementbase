<script lang="ts">
	import type { PageProps } from './$types';
	let { data }: PageProps = $props();

    import * as Accordion from "$lib/components/ui/accordion";
    import Button from '$lib/components/ui/button/button.svelte';
    import { Input } from "$lib/components/ui/input";
    import * as Table from "$lib/components/ui/table";

    let disabled = $state(true);

</script>

<h1>{data.result.germplasmName}</h1>

<!-- Main Data Table -->
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

                    <Button class="float-left" variant="outline" onclick={() => {disabled=!disabled}}>Edit</Button>
                    {#if !disabled}
                        <Button class="float-left ml-4">Submit</Button>
                    {/if}
                    <form>
                    <Table.Root class="mt-4  border-1 p-4">
                        <Table.Body>
                            <Table.Row>
                                <Table.Cell class="font-medium">Organism:</Table.Cell>
                                <Table.Cell><Input type="text" value={data.result.species} disabled={disabled}/></Table.Cell>
                            </Table.Row>
                            <Table.Row>
                                <Table.Cell class="font-medium">Type:</Table.Cell>
                                <Table.Cell><Input type="text"/></Table.Cell>
                            </Table.Row>
                            <Table.Row>
                                <Table.Cell class="font-medium">Uniquename:</Table.Cell>
                                {console.log(data.result)}
                                <Table.Cell><Input type="text" value={data.result.germplasmName} disabled={disabled}/></Table.Cell>
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
