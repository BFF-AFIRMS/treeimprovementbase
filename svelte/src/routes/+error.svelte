<script lang="ts">
  import { page } from '$app/stores';
</script>

<h1>{$page.status}: {$page.error.message}</h1>
<p>Oops, the page you're looking for doesn't exist.</p>
<a href="/">Go to homepage</a>

<style>
  h1 {
    /* Add some styling */
  }
  /* etc */
</style>
