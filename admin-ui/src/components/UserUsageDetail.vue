<script setup>
import { ref, watch } from 'vue'
import { fetchUserLogs } from '../api/usage'

const props = defineProps({
  userId: { type: String, required: true },
  days: { type: Number, required: true },
})

const emit = defineEmits(['back'])

const loading = ref(true)
const error = ref(null)
const payload = ref(null)

function formatDateTime(iso) {
  if (!iso) return '-'
  const d = new Date(iso)
  if (Number.isNaN(d.getTime())) return iso
  return d.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: false,
  })
}

/** 管理台展示：将库存 JSON 字符串格式化为多行 JSON */
function formatLlmJson(raw) {
  if (raw == null || raw === '') return ''
  if (typeof raw !== 'string') return String(raw)
  try {
    return JSON.stringify(JSON.parse(raw), null, 2)
  } catch {
    return raw
  }
}

async function load() {
  loading.value = true
  error.value = null
  try {
    payload.value = await fetchUserLogs(props.userId, props.days)
  } catch (e) {
    error.value = e.message
    payload.value = null
  } finally {
    loading.value = false
  }
}

watch(
  () => [props.userId, props.days],
  () => load(),
  { immediate: true },
)
</script>

<template>
  <div class="detail">
    <div class="detail-toolbar">
      <button type="button" class="btn-back" @click="emit('back')">← 返回总览</button>
      <h2 class="detail-title">用户：{{ userId }}</h2>
      <span class="detail-hint">每条记录为一次 AI 请求；时间为服务器记录时刻（精确到秒）</span>
    </div>

    <p v-if="loading" class="loading">加载中…</p>
    <p v-else-if="error" class="error">加载失败: {{ error }}</p>
    <p v-else-if="!payload?.logs?.length" class="empty">该时间范围内暂无请求记录</p>

    <div v-else class="log-list">
      <article v-for="log in payload.logs" :key="log.id" class="log-card">
        <header class="log-meta">
          <span class="log-time">{{ formatDateTime(log.created_at) }}</span>
          <span class="log-tokens">Token: {{ log.total_tokens?.toLocaleString?.() ?? log.total_tokens }}</span>
          <span class="log-provider">{{ log.provider }} / {{ log.model }}</span>
        </header>
        <div v-if="log.user_message != null || log.assistant_message != null" class="conv">
          <div v-if="log.user_message" class="conv-block">
            <strong>用户</strong>
            <pre class="conv-text">{{ log.user_message }}</pre>
          </div>
          <div v-if="log.assistant_message" class="conv-block">
            <strong>AI</strong>
            <pre class="conv-text">{{ log.assistant_message }}</pre>
          </div>
        </div>
        <p v-else class="no-conv">
          未保存对话原文：请在后端 .env 设置 <code>USAGE_LOG_INCLUDE_CONVERSATION=true</code>（默认即为
          true）并<strong>重启后端</strong>；或该记录在关闭此项之后产生。另请确认已执行迁移 003（存在
          user_message / assistant_message 列）。
        </p>

        <details v-if="log.llm_response_json" class="llm-raw">
          <summary class="llm-raw-summary">完整大模型响应（JSON，可折叠）</summary>
          <pre class="llm-raw-json">{{ formatLlmJson(log.llm_response_json) }}</pre>
        </details>
      </article>
    </div>
  </div>
</template>

<style scoped>
.detail-toolbar {
  margin-bottom: 20px;
}

.btn-back {
  padding: 8px 14px;
  border-radius: 8px;
  border: 1px solid #475569;
  background: #334155;
  color: #e2e8f0;
  cursor: pointer;
  font-size: 0.9rem;
  margin-bottom: 12px;
}

.btn-back:hover {
  background: #475569;
}

.detail-title {
  margin: 0 0 8px;
  font-size: 1.25rem;
}

.detail-hint {
  display: block;
  font-size: 0.85rem;
  color: #94a3b8;
}

.log-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.log-card {
  background: #1e293b;
  border-radius: 12px;
  padding: 16px;
  border: 1px solid #334155;
}

.log-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 12px 20px;
  font-size: 0.9rem;
  margin-bottom: 12px;
  color: #cbd5e1;
}

.log-time {
  font-weight: 600;
  color: #38bdf8;
}

.conv-block {
  margin-top: 10px;
}

.conv-block strong {
  display: block;
  font-size: 0.75rem;
  color: #94a3b8;
  margin-bottom: 4px;
}

.conv-text {
  margin: 0;
  white-space: pre-wrap;
  word-break: break-word;
  font-family: ui-monospace, monospace;
  font-size: 0.85rem;
  color: #e2e8f0;
  background: #0f172a;
  padding: 10px 12px;
  border-radius: 8px;
  max-height: 320px;
  overflow: auto;
}

.no-conv {
  margin: 0;
  font-size: 0.85rem;
  color: #64748b;
  line-height: 1.5;
}

.no-conv code {
  font-size: 0.8rem;
  padding: 2px 6px;
  background: #0f172a;
  border-radius: 4px;
  color: #94a3b8;
}

.llm-raw {
  margin-top: 14px;
  border: 1px solid #334155;
  border-radius: 8px;
  background: #0f172a;
  overflow: hidden;
}

.llm-raw-summary {
  padding: 10px 12px;
  cursor: pointer;
  font-size: 0.85rem;
  color: #a5b4fc;
  user-select: none;
  list-style: none;
}

.llm-raw-summary::-webkit-details-marker {
  display: none;
}

.llm-raw-summary::before {
  content: '▶ ';
  display: inline-block;
  margin-right: 6px;
  transition: transform 0.15s ease;
  color: #64748b;
}

.llm-raw[open] .llm-raw-summary::before {
  transform: rotate(90deg);
}

.llm-raw-json {
  margin: 0;
  padding: 12px;
  max-height: 480px;
  overflow: auto;
  font-family: ui-monospace, 'Cascadia Code', monospace;
  font-size: 0.75rem;
  line-height: 1.45;
  color: #cbd5e1;
  border-top: 1px solid #334155;
  white-space: pre;
  word-break: break-all;
}

</style>
