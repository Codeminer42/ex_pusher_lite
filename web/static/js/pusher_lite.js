// NOTE: The contents of pusher file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

const socketParameters = (pusher) => {
  return {app_key: pusher.appKey, guardian_token: pusher.jwt, unique_identifier: pusher.uniqueUserId}
}

const connectSockets = (pusher) => {
  pusher.socket = new Socket(`http://${pusher.host}/socket`, {params: pusher.socketParameters()})
  pusher.socket.connect()
}

const setChannels = (pusher) => {
  pusher.publicChannel = pusher.socket.channel(`lobby:${pusher.appKey}`, {})
  pusher.privateChannel = socket.channel(`lobby:${pusher.appKey}/uid:${pusher.uniqueUserId}`, {})
}

const bindEventsToChannels = (pusher) => {
  for(let [event, callback] of pusher.publicEvents) {
    pusher.publicChannel.on(event, payload => {
      callback(payload)
    })
  }

  for(let [event, callback] of pusher.privateEvents) {
    pusher.privateChannel.on(event, payload => {
      callback(payload)
    })
  }
}

const joinChannels = (pusher) => {
  pusher.publicChannel.join()
    .receive("ok", resp => { console.log("Successfully joined Public Channel", resp) })
    .receive("error", resp => { console.log("Unable to join Public Channel", resp) })

  pusher.privateChannel.join()
    .receive("ok", resp => { console.log("Successfully joined Private Channel", resp) })
    .receive("error", resp => { console.log("Unable to join Private Channel", resp) })
}

export class PusherLite {
  constructor(host, appKey, jwt, uniqueUserId, publicEvents, privateEvents) {
    this.host = host
    this.appKey = appKey
    this.jwt = jwt
    this.uniqueUserId = uniqueUserId
    this.publicEvents = publicEvents || {}
    this.privateEvents = privateEvents || {}
    this.connected = false
  }

  connect() {
    connectSockets(this)
    setChannels(this)
    bindEventsToChannels(this)
    joinChannels(this)
    this.connected = true
  }

  sendPublic(event, payload) {
    if (!this.connected) return;
    this.publicChannel.push(event, payload)
  }

  sendPrivate(event, payload, destinationId) {
    if (!this.connected) return;
    this.publicChannel.push("direct", { uid: destinationId, event: event, payload: payload })
  }
}
