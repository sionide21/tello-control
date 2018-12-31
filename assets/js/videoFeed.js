import { createWebSocket } from "./util/websocket"

const videoFeed = createWebSocket("/video/websocket")
let heartbeat;

videoFeed.binaryType = "arraybuffer"

videoFeed.addEventListener("open", _event => {
  heartbeat = setInterval(() => {
    videoFeed.send("heartbeat")
  }, 10000)
})

videoFeed.addEventListener("error", error => {
  console.error("Socket Error", error)
})

videoFeed.addEventListener("close", message => {
  clearInterval(heartbeat)
})

function subscribe(callback) {
  videoFeed.addEventListener("message", event => {
    callback(new Uint8Array(event.data))
  })
}

export { subscribe }
