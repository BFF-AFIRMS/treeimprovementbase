<script setup lang="ts">
// ref is auto imported by Nuxt
const count = ref(0)
</script>

<template>
  <h1>Hello from Nuxt</h1>
  <button @click="count++">
    Count is: {{ count }}
  </button>
  <br/>
  <a href="/about">About</a>
</template>

<style scoped>
button {
  font-weight: bold;
}
</style>
