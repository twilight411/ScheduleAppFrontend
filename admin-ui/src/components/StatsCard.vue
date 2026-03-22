<script setup>
function formatValue(v) {
  if (v == null || v === '') return '-'
  return typeof v === 'number' ? v.toLocaleString() : v
}

defineProps({
  title: String,
  value: [String, Number],
})
</script>

<template>
  <div class="card">
    <h2>{{ title }}</h2>
    <div class="stat">{{ formatValue(value) }}</div>
  </div>
</template>
