// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

let socket_params =  {app_key: window.appToken, guardian_token: window.guardianToken, unique_identifier: window.username}
let socket = new Socket("/socket", {params: socket_params})
socket.connect()

// Now that you are connected, you can join channels with a topic:
// let channel = socket.channel("topic:subtopic", {})
let channel = socket.channel(`lobby:${window.appToken}`, {})
let channel_direct = socket.channel(`lobby:${window.appToken}/uid:${window.username}`, {})

let list    = $('#message-list')
let message = $('#message')

let MESSAGE_REGEX = /\/d \@'*(.*?)'* (.*)$/

message.on('keypress', event => {
  if (event.keyCode == 13) {
    let message_text = message.val()
    const matches = MESSAGE_REGEX.exec(message_text)

    if(matches) {
      channel.push('direct', { uid: matches[1], event: "new_message", payload: { name: window.username, message: matches[2] } })
    } else {
      channel.push('new_message', { name: window.username, message: message_text })
    }

    message.val('')
  }
})

channel.on('new_message', payload => {
  list.append(`<b>${payload.name || 'Anonymous'}:</b> ${payload.message}<br>`)
  list.prop({scrollTop: list.prop("scrollHeight")})
})

channel_direct.on('new_message', payload => {
  list.append(`Direct Message from: <b>${payload.name || 'Anonymous'}:</b> ${payload.message}<br>`)
  list.prop({scrollTop: list.prop("scrollHeight")})
})

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel_direct.join()
  .receive("ok", resp => { console.log("Joined successfully to direct channel", resp) })
  .receive("error", resp => { console.log("Unable to join direct channel", resp) })

export default socket
