const API_BASE = ''

export async function fetchStats(days) {
  const res = await fetch(`${API_BASE}/api/admin/usage/stats?days=${days}`)
  if (!res.ok) throw new Error(`HTTP ${res.status}`)
  return res.json()
}

export async function fetchByUser(days) {
  const res = await fetch(`${API_BASE}/api/admin/usage/by-user?days=${days}`)
  if (!res.ok) throw new Error(`HTTP ${res.status}`)
  return res.json()
}

export async function fetchDaily(days) {
  const res = await fetch(`${API_BASE}/api/admin/usage/daily?days=${days}`)
  if (!res.ok) throw new Error(`HTTP ${res.status}`)
  return res.json()
}

/** 单用户请求明细（含 created_at 精确到秒；测试用户可有对话原文） */
export async function fetchUserLogs(userId, days, limit = 500) {
  const q = new URLSearchParams({ days: String(days), limit: String(limit) })
  const res = await fetch(
    `${API_BASE}/api/admin/usage/user/${encodeURIComponent(userId)}/logs?${q}`,
  )
  if (!res.ok) throw new Error(`HTTP ${res.status}`)
  return res.json()
}
