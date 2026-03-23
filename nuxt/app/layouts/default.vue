<script setup lang="ts">
    import {
    NavigationMenu,
    NavigationMenuContent,
    NavigationMenuIndicator,
    NavigationMenuItem,
    NavigationMenuLink,
    NavigationMenuList,
    NavigationMenuTrigger,
    NavigationMenuViewport,
    } from '@/components/ui/navigation-menu';

    const navbarHeight = "15";

    useHead({
        title: 'Best Future Forests',
        link: [
            {
            rel: 'stylesheet',
            href: 'https://rsms.me/inter/inter.css',
            },
        ],
    });
</script>

<!-- <head>
	<link rel="stylesheet" href="https://rsms.me/inter/inter.css" />
</head> -->

<template>
  <div class="min-h-{{navbarHeight}} w-full bg-mgray-100 button-box-shadow mb-8">
  <NavigationMenu class="h-full">
    <a  href="/"><img src="~/assets/img/BFF-AFIRMS_logo_LoRes.png" alt="BFF-AFIRMS logo" class="ml-4 mr-4 pt-1 pb-2 h-15"></a>
    <NavigationMenuList class="flex-wrap h-{{navbarHeight}}">

      <!-- Search Menu -->
      <NavigationMenuItem class="hidden md:block h-full">
        <NavigationMenuTrigger class="h-full nav-menu-trigger!" triggerMode="click">Search</NavigationMenuTrigger>
        <NavigationMenuContent class="nav-menu-content">
          <ul class="nav-menu-content-list">
            <li>
              <NavigationMenuLink href="/search" class="nav-menu-link">All</NavigationMenuLink>
              <NavigationMenuLink href="/breeders/search" class="nav-menu-link">Wizard</NavigationMenuLink>
              <NavigationMenuLink href="/search/bulk" class="nav-menu-link">Bulk Search</NavigationMenuLink>
              <NavigationMenuLink href="/search/stocks" class="nav-menu-link">Accessions and Plots</NavigationMenuLink>
              <NavigationMenuLink href="/search/organisms" class="nav-menu-link">Organisms</NavigationMenuLink>
              <NavigationMenuLink href="/search/cross" class="nav-menu-link">Progeny, Parents, Crosses</NavigationMenuLink>
              <NavigationMenuLink href="/search/trials" class="nav-menu-link">Field Trials</NavigationMenuLink>
              <hr class="nav-menu-hr">
              <NavigationMenuLink href="/search/genotyping_trials" class="nav-menu-link">Genotyping Plates</NavigationMenuLink>
              <NavigationMenuLink href="/search/genotyping_data_projects" class="nav-menu-link">Genotyping Projects</NavigationMenuLink>
              <NavigationMenuLink href="/search/genotyping_protocols" class="nav-menu-link">Genotyping Protocols</NavigationMenuLink>
              <NavigationMenuLink href="/search/stocks_using_genotypes" class="nav-menu-link">Accessions Using Genotypes</NavigationMenuLink>
              <NavigationMenuLink href="/search/vectors" class="nav-menu-link">Vector Constructs</NavigationMenuLink>
              <hr class="nav-menu-hr">
              <NavigationMenuLink href="/tools/onto" class="nav-menu-link">Ontology Browser</NavigationMenuLink>
              <NavigationMenuLink href="/search/traits" class="nav-menu-link">Traits</NavigationMenuLink>
              <NavigationMenuLink href="/search/images" class="nav-menu-link">Images</NavigationMenuLink>
              <NavigationMenuLink href="/search/people" class="nav-menu-link">People</NavigationMenuLink>
            </li>
          </ul>
        </NavigationMenuContent>
      </NavigationMenuItem>

      <!-- Manage Menu -->
      <NavigationMenuItem class="hidden md:block h-full">
        <NavigationMenuTrigger class="h-full nav-menu-trigger!">Manage</NavigationMenuTrigger>
        <NavigationMenuContent class="nav-menu-content">
          <ul class="nav-menu-content-list">
            <li>
              <NavigationMenuLink href="/breeders/manage_roles" class="nav-menu-link">User Roles</NavigationMenuLink>
              <NavigationMenuLink href="/breeders/manage_programs" class="nav-menu-link">Breeding Programs</NavigationMenuLink>
              <NavigationMenuLink href="/breeders/locations" class="nav-menu-link">Locations</NavigationMenuLink>
            </li>
          </ul>
        </NavigationMenuContent>
      </NavigationMenuItem>

      <!-- Analyze Menu -->
      <NavigationMenuItem class="hidden md:block h-full" >
        <NavigationMenuTrigger class="h-full nav-menu-trigger!">Analyze</NavigationMenuTrigger>
        <NavigationMenuContent class="nav-menu-content">
          <ul class="nav-menu-content-list">
            <li>
              <NavigationMenuLink href="/analyses" class="nav-menu-link">Stored Analyses</NavigationMenuLink>
            </li>
          </ul>
        </NavigationMenuContent>
      </NavigationMenuItem>

      <!-- About Menu -->
      <NavigationMenuItem class="hidden md:block h-full" >
        <NavigationMenuTrigger class="h-full nav-menu-trigger!">About</NavigationMenuTrigger>
        <NavigationMenuContent class="nav-menu-content">
          <ul class="nav-menu-content-list">
            <li>
              <NavigationMenuLink href="/analyses" class="nav-menu-link">About</NavigationMenuLink>
            </li>
          </ul>
        </NavigationMenuContent>
      </NavigationMenuItem>

      <!-- New Menu -->
      <NavigationMenuItem class="hidden md:block h-full" >
        <NavigationMenuTrigger class="h-full nav-menu-trigger!">New</NavigationMenuTrigger>
        <NavigationMenuContent class="nav-menu-content">
          <ul class="nav-menu-content-list">
            <li>
              <NavigationMenuLink href="/breeders/manage_programs" class="nav-menu-link">Breeding Programs</NavigationMenuLink>
              <NavigationMenuLink href="/search/organisms" class="nav-menu-link">Organisms</NavigationMenuLink>
              <NavigationMenuLink href="/nuxt/" class="nav-menu-link">Nuxt</NavigationMenuLink>
              <NavigationMenuLink href="/nuxt/about" class="nav-menu-link">Nuxt About</NavigationMenuLink>
            </li>
          </ul>
        </NavigationMenuContent>
      </NavigationMenuItem>

    </NavigationMenuList>
  </NavigationMenu>
    </div>
<slot />
</template>
