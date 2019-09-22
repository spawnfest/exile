# ExileWeb

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Try the HTTP API!
Create a user account:
```
$ curl -X PUT localhost:4000/api/register -H 'Content-Type: application/json' -d '{"user": {"username": "abrown", "password": "testpass12345"}}'
```

Grab a JWT using your user credentials
```
$ curl -X POST localhost:4000/api/auth/login -H 'Content-Type: application/json' -d '{"user": {"username": "abrown", "password": "testpass12345"}}'

{"token": "mytoken"}
```

Create a new object on a path:
```
curl -X POST localhost:4000/api/store/stuff -H 'Content-Type: application/json' -H 'Authorization: Bearer mytoken' -d '{"my": "data"}'
```

Retrieve your object:
```
curl -X POST localhost:4000/api/store/stuff -H 'Authorization: Bearer mytoken'
```


## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
