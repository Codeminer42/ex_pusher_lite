# ExPusherLite

This is a minimal Pusher.com clone made in Elixir intended to be used as the real-time communications component for web applications built in any language that are in need for Web Sockets support.

### Architecture

You have 3 main resources: Users, Organizations and Applications.

Only a User with `is_root: true` can access the ExAdmin "/admin" endpoint to manage all resources of the system.

A User is Enrolled to an Organization (through the `Enrollment` entity, which can have the `is_admin: true` flag).

An Application is Owned by an Organization (through the `Ownership` entity, which can have the `is_owned: true` flag).

A User can have many access tokens through the `UserToken` entity. Tokens can be invalidated through the `invalidated_at` field.

There is only 1 nested API endpoint of the format: `/api/organizations/:organization_slug/applications/:app_key`.

In order to access this endpoint it is necessary to sign in using a valid UserToken.token:

    curl -X POST --data "token=4036de82-c6ab-11e6-9a53-28cfe91ef193" http://localhost:4000/api/session

That will give you a response in the following format:

    {"jwt":"eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJVc2VyOjEiLCJleHAiOjE0ODMxODExNTgsImlhdCI6MTQ4MjMxNzE1OCwiaXNzIjoiRXhQdXNoZXJMaXRlIiwianRpIjoiNDZmOGYxZGUtOGQ3Yy00NGJhLWJhYTEtMWYyMjBhNDU4ZGE3IiwicGVtIjp7fSwic3ViIjoiVXNlcjoxIiwidHlwIjoiYWNjZXNzIn0.oScVwLC6hoOwdQ_b6xDiN2BITE8v98FoAA5s-0L7_qwMgSPUVzKLgjjjOEDxvXb3wYf4yFyE4kh1vrvbfE5HUA"}

Now you can use the API endpoint like this:

    curl -H "Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJVc2VyOjEiLCJleHAiOjE0ODMxODExNTgsImlhdCI6MTQ4MjMxNzE1OCwiaXNzIjoiRXhQdXNoZXJMaXRlIiwianRpIjoiNDZmOGYxZGUtOGQ3Yy00NGJhLWJhYTEtMWYyMjBhNDU4ZGE3IiwicGVtIjp7fSwic3ViIjoiVXNlcjoxIiwidHlwIjoiYWNjZXNzIn0.oScVwLC6hoOwdQ_b6xDiN2BITE8v98FoAA5s-0L7_qwMgSPUVzKLgjjjOEDxvXb3wYf4yFyE4kh1vrvbfE5HUA" http://localhost:4000/api/organizations/acme-inc/applications

Which in turn will give you the following response:

    {"data":[{"name":"Test App","id":1,"archived_at":null,"app_secret":"40362ea6-c6ab-11e6-94dd-28cfe91ef193","app_key":"40362820-c6ab-11e6-9492-28cfe91ef193"}]}

Now one can broadcast messages to a Channel like this:

    curl -X POST -H "Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhZG1pbiI6WyJyZWFkIiwid3JpdGUiXSwiYXBpIjpbInJlYWQiLCJ3cml0ZSJdLCJhdWQiOiJVc2VyOjEiLCJjaGFubmVsIjpbXSwiZXhwIjoxNDgyNTE3NDM4LCJpYXQiOjE0ODIzNDQ2MzgsImlzcyI6IkV4UHVzaGVyTGl0ZSIsImp0aSI6IjJmYzFjY2VhLTFjM2QtNDA4MS1hZGEwLWQwNGEzZGNkN2Q3ZSIsInBlbSI6e30sInN1YiI6IlVzZXI6MSIsInR5cCI6ImFjY2VzcyJ9.-BLPy-4uf4w6fy1-WOQhVN9GGC2mXFzvJzuuCpmTbg9kL_uERjJ_X4vnY7L1ANhisSRTKRSSB1P5ivTUOu510w" http://localhost:4000/api/organizations/acme-inc/applications/40362820-c6ab-11e6-9492-28cfe91ef193/event/new_message\?name\=John\&message\=Hello

You can also send messages directly to a user like this:

    curl -X POST -H "Authorization: Bearer eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhZG1pbiI6WyJyZWFkIiwid3JpdGUiXSwiYXBpIjpbInJlYWQiLCJ3cml0ZSJdLCJhdWQiOiJVc2VyOjEiLCJjaGFubmVsIjpbXSwiZXhwIjoxNDgyNTE3NDM4LCJpYXQiOjE0ODIzNDQ2MzgsImlzcyI6IkV4UHVzaGVyTGl0ZSIsImp0aSI6IjJmYzFjY2VhLTFjM2QtNDA4MS1hZGEwLWQwNGEzZGNkN2Q3ZSIsInBlbSI6e30sInN1YiI6IlVzZXI6MSIsInR5cCI6ImFjY2VzcyJ9.-BLPy-4uf4w6fy1-WOQhVN9GGC2mXFzvJzuuCpmTbg9kL_uERjJ_X4vnY7L1ANhisSRTKRSSB1P5ivTUOu510w" http://localhost:4000/api/organizations/acme-inc/applications/40362820-c6ab-11e6-9492-28cfe91ef193/event/new_message\?name\=John\&message\=HelloWorld\&uid\=akitaonrails\&direct\=true

The trick to receive direct events is to subscribe to 2 channels, a general broadcast channel and a single-user, uniquely identified channel.

Check out the homepage example for instruction on how to setup the Socket connection (also the `js/socket.js` example).

### Development

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup` - this will create example data from the seeds file
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

To collaborate just follow Pull Request best practices, add tests.

Fabio Akita &copy; Codeminer 42 2016
