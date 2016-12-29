// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

/*!
 * IE10 viewport hack for Surface/desktop Windows 8 bug
 * Copyright 2014-2015 Twitter, Inc.
 * Licensed under MIT (https://github.com/twbs/bootstrap/blob/master/LICENSE)
 */

// See the Getting Started docs for more information:
// http://getbootstrap.com/getting-started/#support-ie10-width

(function () {
  'use strict';

  if (navigator.userAgent.match(/IEMobile\/10\.0/)) {
    var msViewportStyle = document.createElement('style')
    msViewportStyle.appendChild(
      document.createTextNode(
        '@-ms-viewport{width:auto!important}'
      )
    )
    document.querySelector('head').appendChild(msViewportStyle)
  }

})();

window.applicationSubmit = function() {
  var url = $("#application_form").attr('action');
  var applicationName = $("#application_name").val();
  $.ajax({
    type : 'POST',
    url : url,
    headers : {
        Authorization : 'Bearer ' + window.guardian_jwt
    },
    contentType : 'application/x-www-form-urlencoded',
    data : {
      'application[name]' : applicationName
    },
    success : function(response) {
      $("#application_name").val("")
      location.reload();
    },
    error : function(xhr, status, error) {
      var err = eval("(" + xhr.responseText + ")");
      console.log(err);
    }
  });
}

window.applicationDelete = function(formId) {
  var url = $("#" + formId).attr('action');
  if(confirm("Are you sure?")) {
    $.ajax({
      type : 'DELETE',
      url : url,
      headers : {
          Authorization : 'Bearer ' + window.guardian_jwt
      },
      contentType : 'application/x-www-form-urlencoded',
      data : {},
      success : function(response) {
        location.reload();
      },
      error : function(xhr, status, error) {
        var err = eval("(" + xhr.responseText + ")");
        console.log(err);
      }
    });
  }
}
