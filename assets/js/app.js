import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"
import JMuxer from "jmuxer"

import { subscribe } from "./videoFeed"

window.onload = () => {
  const videoPlayer = new JMuxer({
    node: "player",
    mode: "video",
    flushingTime: 40,
    fps: 40
  })

  subscribe(frames => {
    videoPlayer.feed({
      video: frames
    })
  })
}
