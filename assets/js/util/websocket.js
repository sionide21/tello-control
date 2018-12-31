function relativeUrl(path) {
  const url = new URL(path, window.location.href)
  url.protocol = url.protocol.replace("http", "ws")
  return url.href
}

function createWebSocket(path) {
  const url = relativeUrl(path)
  return new WebSocket(url)
}

export { createWebSocket }
