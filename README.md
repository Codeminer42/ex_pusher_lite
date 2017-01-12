# ExPusherLite

This is a minimal Pusher.com clone made in Elixir intended to be used as the real-time communications component for web applications built in any language that are in need for Web Sockets support.

### Server-Side Architecture

You have 3 main resources: Users, Organizations and Applications.

Only a User with `is_root: true` can access the ExAdmin "/admin" endpoint to manage all resources of the system.

A User is Enrolled to an Organization (through the `Enrollment` entity, which can have the `is_admin: true` flag).

An Application is Owned by an Organization (through the `Ownership` entity, which can have the `is_owned: true` flag).

A User can have many access tokens through the `UserToken` entity. Tokens can be invalidated through the `invalidated_at` field.

There is only 1 nested API endpoint of the format: `/api/organizations/:organization_slug/applications/:app_key`.

In order to access this endpoint it is necessary to sign in using a valid UserToken.token:

    curl -X POST --data "token=4036...f193" http://localhost:4000/api/sessions

That will give you a response in the following format:

    {"jwt":"eyJh...5HUA"}

Now you can use the API endpoint like this:

    curl -H "Authorization: Bearer eyJh...5HUA" http://localhost:4000/api/organizations/acme-inc/applications

Which in turn will give you the following response:

    {"data":[{"name":"Test App","id":1,"archived_at":null,"app_secret":"4036...f193","app_key":"4036...f193"}]}

Now one can broadcast messages to a Channel like this:

    curl -X POST -H "Authorization: Bearer eyJh...u510w" http://localhost:4000/api/organizations/acme-inc/applications/4036...f193/event/new_message\?name\=John\&message\=Hello

Check out the homepage example for instruction on how to setup the Socket connection (also the `js/pusher_lite.js` example).

### Client-Side Usage

From your application you must import the "/js/pusher.js":

    <script src="https://expusherlite.cm42.io/js/pusher.js" />

Now you can use it like this (ES5):

    var PusherLite = require("pusher_lite").default;

    var pusher = new PusherLite("4036...f193", {
      jwt: "eyJh...510w",
      uniqueUserId: "user_unique_identifier",
      ssl: true })

    var publicChannel = pusher.subscribe("general")

    publicChannel.bind("new_message", function(payload) {
      var chat = $("#chat")
      chat.append("<p><strong>" + payload.name + "</strong> " + payload.message + "</p>");
      chat.scrollTop(chat.prop("scrollHeight"));
    })

    pusher.joinAll();

Now you can send messages using the APIs as described in the previous sections. This will give you a chance to store or filter the messages before broadcasting into the channels.

Or you can allow unfiltered messages directly down the socket like this:

    publicChannel.trigger("new_message", { "name" : "John", "message" : "Hello" })

### Development

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup` - this will create example data from the seeds file
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Setup using docker:

```bash
$ cp docker-compose.sample.yml docker-compose.yml
$ docker-compose build
$ docker-compose run web mix ecto.setup
$ docker-compose run web npm install
$ docker-compose up web
```

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://www.phoenixframework.org/docs/deployment).

To collaborate just follow Pull Request best practices, add tests.

Fabio Akita &copy; Codeminer 42 2016
