// NOTE: The contents of pusher file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket, Presence} from "phoenix"

const socketParameters = (pusher) => {
  return {app_key: pusher.appKey, guardian_token: pusher.jwt, unique_identifier: pusher.uniqueUserId}
}

const connectSockets = (pusher) => {
  const url = `ws://${pusher.host}/socket`
  let options = pusher.socketOptions;
  options["params"] = socketParameters(pusher)

  pusher.socket = new Socket(url, options)
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

const defaultOnJoin = (id, current, newPres) => {
  if(!current){
    console.log("user has entered for the first time", newPres)
  } else {
    console.log("user additional presence", newPres)
  }
}

const defaultOnLeave = (id, current, leftPres) => {
  if(current.metas.length === 0){
    console.log("user has left from all devices", leftPres)
  } else {
    console.log("user left from a device", leftPres)
  }
}

const defaultSocketSuccess = (resp) => { console.log("Socket joined successfully", resp) }
const defaultSocketError = (resp) => { console.log("Error joining Socket", resp) }

// PusherLite(hostname, application_key, jwt_token, unique_identifier, { publicEvents: {}, privateEvents: {}, socketOptions: {}, onJoin: callback, onLeave: callback, onSocketSuccess: callback, onSocketError: callback}
class PusherLite {
  constructor(host, appKey, jwt, uniqueUserId, opts = {}) {
    if (host)   { this.host   = host }   else { throw "must set the hostname for the socket connection" }
    if (appKey) { this.appKey = appKey } else { throw "must set the application key to connect to" }
    if (jwt)    { this.jwt    = jwt }    else { throw "must set a valid authenticated JWT" }
    if (uniqueUserId) { this.uniqueUserId = uniqueUserId } else { throw "must set a unique identifier for this client" }

    this.publicEvents  = opts.publicEvents || {}
    this.privateEvents = opts.privateEvents || {}
    this.socketOptions = opts.socketOptions || {} // you can pass options directly to the internal Socket
    this.presences = {}

    if (opts.onJoin)  { this.onJoin = opts.onJoin }   else { this.onJoin = defaultOnJoin }
    if (opts.onLeave) { this.onLeave = opts.onLeave } else { this.onLeave = defaultOnLeave }

    this.publicEvents["presence_state"] = state => {
      this.presences = Presence.syncState(this.presences, state, this.onJoin, this.onLeave)
      if (this.publicEvents["custom_presence_state"]) {
        this.publicEvents["custom_presence_state"](this.presences)
      }
    }

    this.publicEvents["presence_diff"] = diff => {
      this.presences =  Presence.syncDiff(this.presences, diff, this.onJoin, this.onLeave)
      if (this.publicEvents["custom_presence_diff"]) {
        this.publicEvents["custom_presence_diff"](this.presences)
      }
    }

    if (opts.onSocketSuccess) { this.socketSuccess = opts.onSocketSuccess } else { this.socketSuccess = defaultSocketSuccess }
    if (opts.onSocketError)   { this.socketError   = opts.onSocketError }   else { this.socketError   = defaultSocketError }

    this.connected = false
  }

  cleanPresences() {
    this.presences = {}
  }

  getPresences() {
    this.presences;
  }

  onSocketSuccess(callback) {
    if (this.connected) throw "must set socket event listeners before calling connect()";
    this.socketSuccess = callback;
  }

  onSocketError(callback) {
    if (this.connected) throw "must set socket event listeners before calling connect()";
    this.socketError = callback;
  }

  listenTo(event, callback) {
    if (this.connected) throw "must set event listeners before calling connect()";
    this.publicEvents[event] = callback;
  }

  privateListenTo(event, callback) {
    if (this.connected) throw "must set event listeners before calling connect()";
    this.privateEvents[event] = callback;
  }

  connect() {
    connectSockets(this)
    setChannels(this)
    bindEventsToChannels(this)
    joinChannels(this)
    this.connected = true
  }

  trigger(event, payload) {
    if (!this.connected) throw "must call connect() before triggering";
    this.publicChannel.push(event, payload)
  }

  triggerDirect(event, payload, destinationId) {
    if (!this.connected) throw "must call connect() before triggering";
    this.publicChannel.push("direct", { uid: destinationId, event: event, payload: payload })
  }
}

export default PusherLite
