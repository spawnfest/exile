# Exile

A Realtime Database-As-A-Service  with REST style resource location and Time Traveling Feature support.

See it live @ https://exile-web.gigalixirapp.com

## Philosophy

An extremely simple to use NoSQL store which follows REST-like resource locators known as paths to locate records and define relations between data.

## Getting Started

### Development

Run Tests
```sh
mix tests
```

Run Dialyzer

```sh
mix dialyzer
```

Generate and View Docs
```sh
mix docs && open doc/index.html
```

Run App Locally

```sh
mix do deps.get, compile
(cd apps/exile_web/assets && npm install)
iex -S mix phx.server
```

```sh
open http://localhost:4000
```

🎉 You will be presented with an interact REPL to play with the RT Database via JS
API!


🎉 You can also interact directly with the store using the Exile Elixir API
Directly via the IEX session. See Docs: `doc/Exile.html#content`


### Real Time Database  🖥️ ⚡ 🖥️

* Goto https://exile-web.gigalixirapp.com/ (or run locally)
* Copy the URL (which contains the sandbox token) into another browser window
* Click `subscribe` which will listen for changes on the "posts" domain path
* Create posts in the other window
* See the Magic ✨ as the changes are relayed to all subscribers

An example scenario:

Using Exile to create a blog completely in client JS, 
submit and edit posts and have them visible to all sessions,
and have `comments` instantly appear in a live fashion in all sessions,
WITHOUT ANY SERVER SIDE CODE 😍 

### API


#### POST

**Create Records**

elixir
```elixir
Exile.post("posts", {author: "holsee", title: "Hello World", body: "...", comments: []})
#=> {:ok, "614e1637-5af1-4bd4-8432-e5ccd3b5cd90"}
```

javascript
```js
exile.post('posts', {author: 'holsee', title: 'Hello World', body: '...', comments: []})
//=>
{
  reference: 'posts',
  result: 'ok',
  value: '04c7fecd-9e3f-408d-8799-fef8d120d93c'
}
```

##### Nested

**Create a nested Record**

elixir: create a comment on a post
```elixir
Exile.post("posts/#{post_id}/comments", %{author: "evadne", body: "nice!"})
#=>
{:ok, "cd3c2478-cc50-4010-b54c-7e6e2f534695"}
```

javascript: create a comment on a post
```js
exile.post(`posts/${post_id}/comments`, {author: 'evadne', body: 'nice!'})
//=>
{
  reference: 'posts/04c7fecd-9e3f-408d-8799-fef8d120d93c/comments',
  result: 'ok',
  value: 'a7cc9516-59d0-4095-970d-25eeb7d0b5be'
}
```

#### GET

🔥 Using REST style locator paths you are able to dig into resources which have been dynamically created! 🔥


elixir: get all posts
```elixir
Exile.get('posts')
# =>
{:ok,
 [
   %{
     id: "88d903d4-4b7e-4735-926d-a54bce4b94cf",
     ts: 1569186483608933000,
     value: %{
       "author" => "holsee",
       "comments" => [
         %{
           id: "cd3c2478-cc50-4010-b54c-7e6e2f534695",
           ts: 1569186483608929000,
           value: %{"author" => "bran", "body" => "Lorem ipsum"}
         }
       ],
       "tags" => ["bill", "ted", "rufus"]
     }
   }
 ]}
```

elixir: get a specific comment
``` elixir
Exile.get("posts/#{post_id}/comments/#{comment_id}")
#=> 
{:ok, %{"author" => "bran", "body" => "Lorem ipsum"}}
```

elixir: get a specific comment author
``` elixir
Exile.get("posts/#{post_id}/comments/#{comment_id}")
#=> 
{:ok, "bran"}
```

javascript: get all posts
```js
{
  reference: 'posts',
  result: 'ok',
  value: [
    {
      id: '4874b3dd-6f67-48dd-8b3f-182ead6362a6',
      ts: 1569186089957471700,
      value: {
        author: 'holsee',
        body: '...',
        comments: [
          {
            id: '6748759c-896b-4e5b-93e9-3f49fa4d06cd',
            ts: 1569186089957465000,
            value: {
              author: 'evadne',
              body: 'nice!'
            }
          }
        ],
        title: 'Hello World'
      }
    }
  ]
}
```

javascript: get all comments on a post
```js
exile.get('posts/${post_id}/comments')
//=>
{
  reference: 'posts/4874b3dd-6f67-48dd-8b3f-182ead6362a6/comments',
  result: 'ok',
  value: [
    {
      id: '6748759c-896b-4e5b-93e9-3f49fa4d06cd',
      ts: 1569186089957465000,
      value: {
        author: 'evadne',
        body: 'nice!'
      }
    }
  ]
}
```


#### PUT

Unlike POST operations which create new records, PUT allows you to update values at a locator path.

elixir: update post body
```elixir
Exile.put("posts/#{post_id}/body", "new body!")
# => :ok

Exile.get("posts/#{post_id}/body")
# =>
{:ok, "new body!"}
```


#### DELETE

You can also delete values at the path:

elixir: delete all posts
```elixir
Exile.delete("posts")
# =>
:ok
```

javascript: delete all posts
```js
exile.delete('posts')
```

#### Subscribe to path (Realtime features  🖥️ ⚡ 🖥️)

elixir: subscribe to posts, get update event
```elixir
subscriber_address = self()
Exile.subscribe("posts", subscriber_address)
#=> 
:ok

#when post is created or updated receive event:
flush()
#=>
{:exile_event,
 {:update, "posts/e5373a79-8b76-464f-b72a-8182a1ed6230/body",
  {"e5373a79-8b76-464f-b72a-8182a1ed6230", 1569187403304193274,
   %{
     "author" => "holsee",
     "body" => "new body!",
     "comments" => [
       %{
         id: "787b20f6-643f-454d-9a87-f9fd985b4458",
         ts: 1569186933359652898,
         value: %{"author" => "bran", "body" => "Lorem ipsum"}
       }
     ],
     "tags" => ["bill", "ted", "rufus"]
   }}}}
```


javascript: subscribe to posts, get new item event
```js
exile.subscribe('posts')
#=> 
{
  result: 'ok'
}

# when post is created receive event 
#=>
{
  event_type: 'new',
  path: '37469d37-21f9-4ea5-b2a9-ebe136d8c3cc:posts',
  record: {
    id: 'd9f0db63-2f3d-422d-b9d7-bccc549d3e65',
    timestamp: 1569187287039046000,
    value: {
      comments: [],
      title: 'Hello World'
    }
  }
}
```

#### Time Traveling 🕓🕒🕑

At a storage level records are immutable and every change results in a new version.
By default the latest version is returned.

There is no public API support for this (ironically we ran out of time 🥁🤣) but as we have the foundations in place as detailed, we envision an API like the following being completely possible:

get last 10 revisions of a post:
```js
exile.get('posts/${post_id}', {last: 10})
```

get versions between timestamps:
```js
exile.get('posts/${post_id}', {from: 1569186663, to: 1569187763})
```

