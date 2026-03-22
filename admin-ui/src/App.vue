<script setup>
import { ref, watch } from 'vue'
import StatsCard from './components/StatsCard.vue'
import UsageTable from './components/UsageTable.vue'
import UserUsageDetail from './components/UserUsageDetail.vue'
import { fetchStats, fetchByUser, fetchDaily } from './api/usage'

const days = ref(7)
/** 非空时显示单用户明细 */
const selectedUserId = ref(null)
const stats = ref(null)
const byUser = ref([])
const daily = ref([])
const error = ref(null)

async function load() {
  error.value = null
  try {
    const [s, u, d] = await Promise.all([
      fetchStats(days.value),
      fetchByUser(days.value),
      fetchDaily(days.value),
    ])
    stats.value = s
    byUser.value = u
    daily.value = d
  } catch (e) {
    error.value = e.message
    byUser.value = []
    daily.value = []
  }
}

watch(days, load, { immediate: true })

const userColumns = [
  { key: 'user_id', label: '用户' },
  { key: 'total_tokens', label: 'Token' },
  { key: 'request_count', label: '请求数' },
]
const dailyColumns = [
  { key: 'date', label: '日期' },
  { key: 'total_tokens', label: 'Token' },
  { key: 'request_count', label: '请求数' },
]
</script>

<template>
  <UserUsageDetail
    v-if="selectedUserId"
    :user-id="selectedUserId"
    :days="days"
    @back="selectedUserId = null"
  />

  <template v-else>
  <header class="header">
    <h1>📊 Schedule App 用量监控</h1>
    <select v-model.number="days" class="days-select">
      <option :value="7">近 7 天</option>
      <option :value="14">近 14 天</option>
      <option :value="30">近 30 天</option>
    </select>
  </header>

  <main class="main">
    <section class="stats-grid">
      <StatsCard title="总 Token 用量" :value="stats?.total_tokens" />
      <StatsCard title="请求次数" :value="stats?.request_count" />
      <StatsCard title="Prompt Tokens" :value="stats?.prompt_tokens" />
      <StatsCard title="Completion Tokens" :value="stats?.completion_tokens" />
    </section>

    <section class="card">
      <h2>按用户用量排行</h2>
      <p class="table-hint">点击某一用户行可查看每次请求的精确时间与 Token（测试用户可查看已保存的对话原文）。</p>
      <p v-if="error" class="error">加载失败: {{ error }}</p>
      <UsageTable
        v-else
        :columns="userColumns"
        :rows="byUser"
        bar-key="total_tokens"
        row-clickable
        @row-click="selectedUserId = $event.user_id"
      />
    </section>

    <section class="card">
      <h2>按日趋势</h2>
      <UsageTable
        v-if="!error"
        :columns="dailyColumns"
        :rows="daily"
        bar-key="total_tokens"
      />
    </section>
  </main>
  </template>
</template>
