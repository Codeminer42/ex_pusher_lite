// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .

$(document).ready(function() {
  var PusherLite = require("pusher_lite").default;

  var pusher = new PusherLite(window.app_key, {
    host: window.pusher_host,
    jwt: window.guardian_token,
    uniqueUserId: "robot",
    ssl: true})

  var publicChannel = pusher.subscribe("general")

  publicChannel.bind("new_message", function(payload) {
    var chat = $("#chat")
    chat.append("<p><strong>" + payload.name + "</strong> " + payload.message + "</p>");
    chat.scrollTop(chat.prop("scrollHeight"));
  })

  pusher.joinAll();

  var message_element = $("#message");
  message_element.on('keypress', function(event) {
    if (event.keyCode != 13) { return; }

    var name_element    = $("#name");
    var check_element   = $("#channel");
    var payload = { name: name_element.val(), message: message_element.val() };

    if(!check_element.prop("checked")) {
      sendPusher(payload);
    } else {
      sendAPI(payload)
    }
    message_element.val('');
  });

  window.publicChannel = publicChannel;
})

function sendPusher(payload) {
  console.log("sending through socket")
  window.publicChannel.trigger('new_message', payload );
}

function sendAPI(payload) {
  console.log("sending through API")
  $.ajax({
    type : 'POST',
    crossDomain: true,
    url : makeURL("new_message"),
    headers : { Authorization : 'Bearer ' + window.guardian_token },
    data : payload,
    success : function(response) {
      console.log(response);
      console.log("sent through API successfully");
    },
    error : function(xhr, status, error) {
      console.log(error);
    }
  });
}

function makeURL(event) {
  return "http://" + window.pusher_host + "/api/organizations/" + window.org_id + "/applications/" + window.app_key + "/event/" + event;
}
