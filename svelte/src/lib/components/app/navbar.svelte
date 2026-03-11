<script lang="ts">
  import { asset, resolve } from '$app/paths';
  import * as NavigationMenu from "$lib/components/ui/navigation-menu/index.js";

  const navbarHeight = "15";

</script>


<!-- <NavigationMenu.Root viewport={isMobile.current}> -->
<div class="min-h-{navbarHeight} w-full bg-mgray-100 button-box-shadow mb-8">
  <NavigationMenu.Root viewport={false} class="h-full">
    <a  href={resolve("/")}><img src={asset("/img/BFF-AFIRMS_logo_LoRes.png")} alt="BFF-AFIRMS logo" class="ml-4 mr-4 pt-1 pb-2 h-15"></a>

    <NavigationMenu.List class="flex-wrap h-{navbarHeight}">

      <!-- Search Menu -->
      <NavigationMenu.Item class="hidden md:block h-full" openOnHover={false}>
        <NavigationMenu.Trigger class="h-full nav-menu-trigger!">Search</NavigationMenu.Trigger>
        <NavigationMenu.Content class="nav-menu-content">
          <ul class="nav-menu-content-list">
            <li>
              <NavigationMenu.Link href="/search" class="nav-menu-link">All</NavigationMenu.Link>
              <NavigationMenu.Link href="/breeders/search" class="nav-menu-link">Wizard</NavigationMenu.Link>
              <NavigationMenu.Link href="/search/bulk" class="nav-menu-link">Bulk Search</NavigationMenu.Link>
              <NavigationMenu.Link href="/search/stocks" class="nav-menu-link">Accessions and Plots</NavigationMenu.Link>
              <NavigationMenu.Link href="/search/organisms" class="nav-menu-link">Organisms</NavigationMenu.Link>
              <NavigationMenu.Link href="/search/cross" class="nav-menu-link">Progeny, Parents, Crosses</NavigationMenu.Link>
              <NavigationMenu.Link href="/search/trials" class="nav-menu-link">Field Trials</NavigationMenu.Link>
              <hr class="nav-menu-hr">
              <NavigationMenu.Link href="/search/genotyping_trials" class="nav-menu-link">Genotyping Plates</NavigationMenu.Link>
              <NavigationMenu.Link href="/search/genotyping_data_projects" class="nav-menu-link">Genotyping Projects</NavigationMenu.Link>
              <NavigationMenu.Link href="/search/genotyping_protocols" class="nav-menu-link">Genotyping Protocols</NavigationMenu.Link>
              <NavigationMenu.Link href="/search/stocks_using_genotypes" class="nav-menu-link">Accessions Using Genotypes</NavigationMenu.Link>
              <NavigationMenu.Link href="/search/vectors" class="nav-menu-link">Vector Constructs</NavigationMenu.Link>
              <hr class="nav-menu-hr">
              <NavigationMenu.Link href="/tools/onto" class="nav-menu-link">Ontology Browser</NavigationMenu.Link>
              <NavigationMenu.Link href="/search/traits" class="nav-menu-link">Traits</NavigationMenu.Link>
              <NavigationMenu.Link href="/search/images" class="nav-menu-link">Images</NavigationMenu.Link>
              <NavigationMenu.Link href="/search/people" class="nav-menu-link">People</NavigationMenu.Link>
            </li>
          </ul>
        </NavigationMenu.Content>
      </NavigationMenu.Item>

      <!-- Manage Menu -->
      <NavigationMenu.Item class="hidden md:block h-full" openOnHover={false}>
        <NavigationMenu.Trigger class="h-full nav-menu-trigger!">Manage</NavigationMenu.Trigger>
        <NavigationMenu.Content class="nav-menu-content">
          <ul class="nav-menu-content-list">
            <li>
              <NavigationMenu.Link href="/breeders/manage_roles" class="nav-menu-link">User Roles</NavigationMenu.Link>
              <NavigationMenu.Link href="/breeders/manage_programs" class="nav-menu-link">Breeding Programs</NavigationMenu.Link>
              <NavigationMenu.Link href="/breeders/locations" class="nav-menu-link">Locations</NavigationMenu.Link>
            </li>
          </ul>
        </NavigationMenu.Content>
      </NavigationMenu.Item>

      <!-- Analyze Menu -->
      <NavigationMenu.Item class="hidden md:block h-full" openOnHover={false}>
        <NavigationMenu.Trigger class="h-full nav-menu-trigger!">Analyze</NavigationMenu.Trigger>
        <NavigationMenu.Content class="nav-menu-content">
          <ul class="nav-menu-content-list">
            <li>
              <NavigationMenu.Link href="/analyses" class="nav-menu-link">Stored Analyses</NavigationMenu.Link>
            </li>
          </ul>
        </NavigationMenu.Content>
      </NavigationMenu.Item>

      <!-- About Menu -->
      <NavigationMenu.Item class="hidden md:block h-full" openOnHover={false}>
        <NavigationMenu.Trigger class="h-full nav-menu-trigger!">About</NavigationMenu.Trigger>
        <NavigationMenu.Content class="nav-menu-content">
          <ul class="nav-menu-content-list">
            <li>
              <NavigationMenu.Link href="/analyses" class="nav-menu-link">About</NavigationMenu.Link>
            </li>
          </ul>
        </NavigationMenu.Content>
      </NavigationMenu.Item>

      <!-- New Menu -->
      <NavigationMenu.Item class="hidden md:block h-full" openOnHover={false}>
        <NavigationMenu.Trigger class="h-full nav-menu-trigger!">New</NavigationMenu.Trigger>
        <NavigationMenu.Content class="nav-menu-content">
          <ul class="nav-menu-content-list">
            <li data-sveltekit-reload>
              <NavigationMenu.Link href={resolve("/breeders/manage_programs")} class="nav-menu-link">Breeding Programs</NavigationMenu.Link>
              <NavigationMenu.Link href={resolve("/search/organisms")} class="nav-menu-link">Organisms</NavigationMenu.Link>
            </li>
          </ul>
        </NavigationMenu.Content>
      </NavigationMenu.Item>
    </NavigationMenu.List>
  </NavigationMenu.Root>
</div>
