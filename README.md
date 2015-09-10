# Maia

This project maintains a `Maia::Device` model and facilitates the delivery of push notifications for iOS and Android through GCM3.

## Installation

```
gem 'maia'
bundle
bin/rake railties:install:migrations
bin/rake db:migrate
```

This will copy the `maia_devices` table into your project.

## Setup

Under the hood, Maia uses the [Mercurius](https://github.com/jrbeck/mercurius) gem to send pushes. Check out it's configuration
before you continue with Maia.

Maia relies on [ActiveJob](https://github.com/rails/rails/tree/master/activejob) to enqueue messages. Ensure your application is properly setup with ActiveJob!

Include `Maia::Model` into your User model. This will attach the `has_many` relationship you need with `Maia::Device`:

```ruby
class User
  include Maia::Model
  # ...
end
```

Create a Devices controller where you need it, which is most likely an API. The controller itself will be generated within your application so that
Maia does not make any assumptions about your method of authentication, `respond_with` mimetypes, etc. The only requirement is that `current_user`
exists.

Here's an example of getting setup with an API Devices controller that mobile apps can register with:

`bin/rails g controller api/devices`

After the controller is generated, include `Maia::Controller`:

```ruby
class Api::DevicesController
  include Maia::Controller
  # ...
```

Maia provides the `create` method for you, so devices can now register themselves by POSTing to that controller. If you'd like to add any other actions, feel free.

## Device Registration

Devices can register with your application by submitting a POST to your devices controller with these params:

```
{ "device": { "token": "<TOKEN>" } }
```

Where `<TOKEN>` is the token from GCM registration.

## Expiration

Devices will expire after 14 days. This is to ensure user's who sell or otherwise give away their device will not be tied to that device forever. Each
time a POST to Devices is received, the token expiration will be refreshed.

## Defining Messages

Maia provides a `Maia::Message` class that provides an interface for defining push messages and sending them. The methods for defining a push are
`alert`, `badge`, `sound`, and `other`.

For example:

```ruby
class ExampleMessage < Maia::Message
  def alert
    'This is an example'
  end

  def badge
    2
  end

  def sound
    'default'
  end

  def other
    { foo: :bar }
  end
end
```

Will generate the following GCM payload (see [this table](https://developers.google.com/cloud-messaging/http-server-ref#table1) for parameter details):

```json
{
  "data": {
    "foo": "bar"
  },
  "content_available": false,
  "notification": {
    "title": "This is an example",
    "body": "This is an example",
    "sound": "default",
    "badge": 2
  },
  "registration_ids": ["<TOKEN1>", "<TOKEN2>"]
}
```

`Maia::Message` does not define a constructor so you can construct your message however you want.

## iOS Content available

To send `"content_available": true` with the GCM payload, override `content_available?` in your message to return a truthy value:

```ruby
class ExampleMessage < Maia::Message
  # ...

  def content_available?
    true
  end
end
```

## Sending messages

`Maia::Message` provides a `send_to` that pushes the message out to a user (or collection of users). The argument to `send_to` should be a
single record or relation.

For example:

```ruby
ExampleMessage.new(...).send_to User.first
# or
ExampleMessage.new(...).send_to User.where(beta: true)
```

## Sending a test push

Maia comes with a built-in message to use to test your configuration out:

```ruby
Maia::Poke.new.send_to user
```

Will send the alert "Poke" to the device.
