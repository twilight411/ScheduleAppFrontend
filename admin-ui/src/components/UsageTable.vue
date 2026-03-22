<script setup>
import { computed } from 'vue'

const props = defineProps({
  columns: Array,
  rows: Array,
  barKey: String,
  /** 为 true 时整行可点击，用于按用户排行进入详情 */
  rowClickable: { type: Boolean, default: false },
})

defineEmits(['row-click'])

const maxBar = computed(() => {
  if (!props.barKey || !props.rows?.length) return 1
  return Math.max(1, ...props.rows.map((r) => r[props.barKey]))
})

function formatCell(val, key) {
  if (val == null) return '-'
  if (typeof val === 'number') return val.toLocaleString()
  return val
}
</script>

<template>
  <div v-if="!rows?.length" class="empty">暂无数据</div>
  <table v-else>
    <thead>
      <tr>
        <th v-for="col in columns" :key="col.key">{{ col.label }}</th>
        <th v-if="barKey">占比</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="(row, i) in rows"
        :key="i"
        :class="{ clickable: rowClickable }"
        @click="rowClickable && $emit('row-click', row)"
      >
        <td v-for="col in columns" :key="col.key">
          {{ formatCell(row[col.key], col.key) }}
        </td>
        <td v-if="barKey">
          <div class="bar">
            <span :style="{ width: `${(row[barKey] / maxBar) * 100}%` }"></span>
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>
