.pragma library

function emptySample() {
  return {
    cpu: { percent: 0, cores: [] },
    cpuTemp: { packageC: 0, cores: [] },
    ram: { percent: 0, usedBytes: 0, totalBytes: 0, availableBytes: 0 },
    gpu: null
  }
}

function parseSample(raw) {
  try {
    var data = JSON.parse(String(raw || "{}"))
    if (!data || typeof data !== "object")
      return emptySample()
    return {
      cpu: data.cpu || { percent: 0, cores: [] },
      cpuTemp: data.cpuTemp || { packageC: 0, cores: [] },
      ram: data.ram || { percent: 0, usedBytes: 0, totalBytes: 0, availableBytes: 0 },
      gpu: data.gpu || null
    }
  } catch (e) {
    return emptySample()
  }
}

function pushHistory(history, value, maxLen) {
  var arr = history instanceof Array ? history.slice() : []
  arr.push(Math.max(0, Number(value) || 0))
  var cap = maxLen || 30
  if (arr.length > cap)
    arr = arr.slice(arr.length - cap)
  return arr
}

function formatPercent(value) {
  return String(Math.round(Number(value) || 0)) + "%"
}

function formatTemp(celsius) {
  return String(Math.round(Number(celsius) || 0)) + "°"
}

function formatBytes(bytes) {
  var n = Number(bytes) || 0
  if (n <= 0)
    return "0G"
  var gib = n / (1024 * 1024 * 1024)
  if (gib >= 10)
    return String(Math.round(gib)) + "G"
  return (Math.round(gib * 10) / 10).toFixed(1) + "G"
}

function formatRam(sample) {
  if (!sample)
    return "0%"
  return formatPercent(sample.percent)
}

function historyMax(history, fallbackMin) {
  var maxV = fallbackMin || 100
  if (!(history instanceof Array))
    return maxV
  for (var i = 0; i < history.length; i++) {
    var v = Number(history[i]) || 0
    if (v > maxV)
      maxV = v
  }
  return Math.max(fallbackMin || 100, Math.ceil(maxV / 10) * 10)
}

function clampInt(value, min, max, fallback) {
  var n = parseInt(value, 10)
  if (isNaN(n))
    return fallback
  return Math.max(min, Math.min(max, n))
}
