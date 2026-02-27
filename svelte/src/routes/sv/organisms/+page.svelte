<script lang="ts">
  import { Button } from "$lib/components/ui/button/index.js";
  import * as Accordion from "$lib/components/ui/accordion/index.js";
  import * as Field from "$lib/components/ui/field/index.js";
  import { Input } from "$lib/components/ui/input/index.js";

  const fields = Object.entries({
    'species':     {'name': 'Species',     'placeholder': 'Pinus contorta'},
    'common_name': {'name': 'Common Name', 'placeholder': 'Lodgepole pine' },
  });
</script>

<h1>Organism/Taxon Search</h1>

<Accordion.Root type="single" value="search">
  <Accordion.Item value="search">
    <Accordion.Trigger class="p-1">
      <span class="text-sm! m-0!">Search</span>
    </Accordion.Trigger>
    <hr class="pt-2! m-0">
    <Accordion.Content>
      <div class="bg-mgray-100 border border-mgray-400 rounded-md p-4 shadow-sm">
        <form>
          <Field.Group>
            <Field.Set>
              <Field.Group class="gap-4">

                {#each fields as [id, info]}
                <Field.Field orientation="responsive" class="sm:grid sm:grid-cols-4">
                  <Field.Label for="{id}" class="whitespace-nowrap col-span-1 text-left inline-grid sm:text-right">{info.name}:</Field.Label>
                  <Input id="{id}" placeholder="{info.placeholder}" class="shadow-xs border-stone-300 w-full! col-span-3"/>
                </Field.Field>
                {/each}

                <Field.Field orientation="horizontal" class="block text-center">
                  <Button type="submit" class="shadow-xs bg-green-700 border border-green-800 text-xs p-2 h-7 rounded">Submit</Button>
              </Field.Field>
              </Field.Group>

            </Field.Set>
          </Field.Group>
        </form>
      </div>
    </Accordion.Content>
  </Accordion.Item>
</Accordion.Root>
