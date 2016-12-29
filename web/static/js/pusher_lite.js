// NOTE: The contents of pusher file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

const socketParameters = (pusher) => {
  return {app_key: pusher.appKey, guardian_token: pusher.jwt, unique_identifier: pusher.uniqueUserId}
}

const connectSockets = (pusher) => {
  const url = `ws://${pusher.host}/socket`
  pusher.socket = new Socket(url, {params: socketParameters(pusher)})
  pusher.socket.connect()
}

const setChannels = (pusher) => {
  pusher.publicChannel = pusher.socket.channel(`lobby:${pusher.appKey}`, {})
  pusher.privateChannel = pusher.socket.channel(`lobby:${pusher.appKey}/uid:${pusher.uniqueUserId}`, {})
}

const bindEventsToChannels = (pusher) => {
  for(let [event, callback] of Object.entries(pusher.publicEvents)) {
    pusher.publicChannel.on(event, payload => {
      callback(payload)
    })
  }

  for(let [event, callback] of Object.entries(pusher.privateEvents)) {
    pusher.privateChannel.on(event, payload => {
      callback(payload)
    })
  }
}

const joinChannels = (pusher) => {
  pusher.publicChannel.join()
    .receive("ok", resp => { pusher.socketSuccess(resp) })
    .receive("error", resp => { pusher.socketError(resp) })

  pusher.privateChannel.join()
    .receive("ok", resp => { pusher.socketSuccess(resp) })
    .receive("error", resp => { pusher.socketError(resp) })
}

class PusherLite {
  constructor(host, appKey, jwt, uniqueUserId, publicEvents, privateEvents) {
    this.host = host
    this.appKey = appKey
    this.jwt = jwt
    this.uniqueUserId = uniqueUserId
    this.publicEvents = publicEvents || {}
    this.privateEvents = privateEvents || {}
    this.connected = false

    this.socketSuccess = (resp) => { console.log("Socket joined successfully", resp) }
    this.socketError = (resp) => { console.log("Error joining Socket", resp) }
  }

  onSocketSuccess(callback) {
    this.socketSuccess = callback;
  }

  onSocketError(callback) {
    this.socketError = callback;
  }

  connect() {
    connectSockets(this)
    setChannels(this)
    bindEventsToChannels(this)
    joinChannels(this)
    this.connected = true
  }

  trigger(event, payload) {
    if (!this.connected) return;
    this.publicChannel.push(event, payload)
  }

  triggerDirect(event, payload, destinationId) {
    if (!this.connected) return;
    this.publicChannel.push("direct", { uid: destinationId, event: event, payload: payload })
  }
}

export { PusherLite }
