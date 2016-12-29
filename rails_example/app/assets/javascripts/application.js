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
  var PusherLite = require("web/static/js/pusher_lite").PusherLite;

  // event coming from the channel
  var publicEvents = {
    "new_message" : function(payload) {
      var chat = $("#chat")
      chat.append("<p><strong>" + payload.name + "</strong> " + payload.message + "</p>");
      chat.scrollTop(chat.prop("scrollHeight"));
    }
  }

  var pusher = new PusherLite(window.pusher_host,
    window.app_key, window.guardian_token, "robot", publicEvents, {})
  pusher.connect();

  var message = $("#message");
  message.on('keypress', function(event) {
    if (event.keyCode == 13) {
      if(!$("#channel").prop("checked")) {
        console.log("sending through socket")
        pusher.trigger('new_message', { name: $("#name").val(), message: message.val() });
      } else {
        console.log("sending through API")
        $.ajax({
          type : 'POST',
          crossDomain: true,
          url : "http://" + window.pusher_host + "/api/organizations/" + window.org_id + "/applications/" + window.app_key + "/event/new_message",
          headers : {
              Authorization : 'Bearer ' + window.guardian_token
          },
          contentType : 'application/x-www-form-urlencoded',
          data : {
            'name' : $("#name").val(),
            'message' : message.val()
          },
          success : function(response) {
          },
          error : function(xhr, status, error) {
            console.log(error);
          }
        });
      }
      message.val('');
    }
  });
})
