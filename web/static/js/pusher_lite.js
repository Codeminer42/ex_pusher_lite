// NOTE: The contents of pusher file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket, Presence} from "phoenix"

const socketParameters = (pusher) => {
  return {app_key: pusher.appKey, guardian_token: pusher.jwt, unique_identifier: pusher.uniqueUserId}
}

const connectSockets = (pusher, ssl = false) => {

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

const defaultSocketSuccess = (resp) => {
  console.log("Socket joined successfully", resp)
}

const defaultSocketError = (resp) => {
  console.log("Error joining Socket", resp)
}

class PusherLiteChannel {
  constructor(topic, pusher, opts = {}) {
    this.topic    = topic;
    this.pusher   = pusher;
    this.channel  = pusher.socket.channel(`lobby:${pusher.appKey}:${topic}`);
    this.presence = {};

    if (opts.onJoin)  { this.onJoin  = opts.onJoin }  else { this.onJoin  = defaultOnJoin }
    if (opts.onLeave) { this.onLeave = opts.onLeave } else { this.onLeave = defaultOnLeave }

    if (opts.onSuccess) { this.onSuccess = opts.onSuccess } else { this.onSuccess = defaultSocketSuccess }
    if (opts.onError)   { this.onError   = opts.onError }   else { this.onError   = defaultSocketError }

    this.channel.on("presence_state", state => { this.handle("presence_state", state) } )
    this.channel.on("presence_diff", diff => { this.handle("presence_diff", diff) } )
  }

  getTopic() { return this.topic }

  getPresence() { return this.presence }

  bind(event, callback) {
    this.channel.on(event, callback);
  }

  join(onSuccess, onError) {
    this.channel.join()
      .receive("ok", resp => { this.onSuccess(resp) })
      .receive("error", resp => { this.onError(resp) })
  }

  trigger(event, payload) {
    this.channel.push(event, payload)
  }

  handle(event, state) {
    this.presence = Presence.syncState(this.presence, state, this.onJoin, this.onLeave)
    if(event == "presence_state" && this.pusher.presenceState)
      pusher.presenceState(state)
    if(event == "presence_diff" && this.pusher.presenceDiff)
      pusher.presenceDiff(state)
  }
}

// PusherLite(hostname, application_key, jwt_token, unique_identifier, { publicEvents: {}, privateEvents: {}, socketOptions: {}, onJoin: callback, onLeave: callback, onSocketSuccess: callback, onSocketError: callback}
class PusherLite {
  constructor(appKey, opts = {}) {
    if (appKey)    { this.appKey = appKey }    else { throw "must set the application key to connect to" }
    if (opts.host) { this.host   = opts.host } else { this.host = "expusherlite.cm42.io" }
    if (opts.jwt)  { this.jwt    = opts.jwt }  else { throw "must set a valid authenticated JWT" }
    if (opts.uniqueUserId) { this.uniqueUserId = opts.uniqueUserId } else { throw "must set a unique identifier for this client" }

    if (opts.onSocketSuccess) { this.socketSuccess = opts.onSocketSuccess } else { this.socketSuccess = defaultSocketSuccess }
    if (opts.onSocketError)   { this.socketError   = opts.onSocketError }   else { this.socketError   = defaultSocketError }

    this.channels = {}

    this.socketOptions = opts.socketOptions || {} // you can pass options directly to the internal Socket
    this.socketOptions["params"] = socketParameters(this)

    this.socket = new Socket(`${ (opts.ssl ? 'wss' : 'ws') }://${this.host}/socket`, this.socketOptions)
    this.socket.connect()
  }

  subscribe(topic, opts = {}) {
    this.channels[topic] = new PusherLiteChannel(topic, this, opts)
    return this.channels[topic]
  }

  joinAll() {
    for(let [topic, channel] of Object.entries(this.channels)) {
      channel.join()
    }
  }
}

export default PusherLite
