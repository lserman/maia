# Maia

This project maintains a `Maia::Device` model and facilitates the delivery of push notifications for iOS and Android through FCM (Firebase Cloud Messaging).

As of Maia 5, only the FCM HTTP v1 is supported. Use an older version of Maia if
you need to use the FCM legacy API.

## Installation

```
gem 'maia'
bundle
bin/rake railties:install:migrations
bin/rake db:migrate
```

This will copy the `maia_devices` table into your project.

### Messenger configuration

Maia is setup to use [ActiveJob](https://github.com/rails/rails/tree/master/activejob)
as it's default messenger. If you want to send messages inline instead, use the inline adapter:

```
Maia.messenger = Maia::Messengers::Inline.new
```

or set it to anything that responds to `#deliver(payload)`.

### Gateway configuration

Maia uses the FCM HTTP v1 gateway by default. This assumes you are using `['GOOGLE_APPLICATION_CREDENTIALS']`
for authentication, so you should be good to go if this environment variable is set. If not, you can pass a custom
object to the FCM gateway as long as it responds to `#project` and `#token`.

```
Maia.gateway = Maia::FCM::Gateway.new CustomFCMCredentials.new
```

### Rails configuration

Include `Maia::Model` into your User model. This will attach the `has_many` relationship you need with `Maia::Device`:

```ruby
class User
  include Maia::Model
end
```

## Device Registration

Create a Devices controller where you need it, which is most likely an API. The controller itself will be generated within your application so that Maia does not make any assumptions about your method of authentication, `respond_with` mimetypes, etc. The only requirement is that `current_user` exists and returns whatever model included `Maia::Model`.

Here's an example of getting setup with an API Devices controller that mobile apps can register with:

`bin/rails g controller api/devices`

After the controller is generated, include `Maia::Controller`:

```ruby
class API::DevicesController
  include Maia::Controller
  # ...
```

Maia provides the `create` method for you, so devices can now register themselves by POSTing to that controller. If you'd like to add any other actions, feel free.

Devices can register with your application by submitting a POST to your devices controller with these params:

```
{ "device": { "token": "<TOKEN>" } }
```

Where `<TOKEN>` is the token from FCM registration. Maia will automatically destroy devices when FCM responds with an `UNREGISTERED` error.

## Device Expiration

Devices will expire after 14 days. This is to ensure users who sell or otherwise give away their device will not be tied to that device forever. Each time a POST to Devices is received, the token expiration will be refreshed.

## Defining Messages

Maia provides a `Maia::Message` class that provides an interface for defining push messages and sending them. To define a message, inherit from `Maia::Message` and override whatever you need to:

```ruby
class ExampleMessage < Maia::Message
  # Required
  def title
    'Something happened!'
  end

  # Required, the body of the message on Android, alert on iOS
  def body
    'Something very important has happened, check it out!'
  end

  # Determines the icon to load on Android phones
  def image
    'icn_maia'
  end

  # Sound to play on arrival (nil by default)
  def sound
    'default'
  end

  # Badge to use on iOS (nil by default)
  def badge
    1
  end

  # #RRGGBB formatted color to use for the Android notification icon
  def color
    '#ffffff'
  end

  # Any additional data to send with the payload
  def data
    { foo: :bar }
  end

  # :normal or :high (:normal by default)
  def priority
    :normal
  end

  # Override to true in order to send the iOS content-available flag
  def background?
    false
  end
end
```

`Maia::Message` does not define a constructor so you can construct your message however you want.

## Sending messages

`Maia::Message` provides a `send_to` method that pushes the message out to a user (or collection of users). The argument to `send_to` should be a single record or relation of records.

For example:

```ruby
ExampleMessage.new(...).send_to User.first
ExampleMessage.new(...).send_to User.where(beta: true)
```

You can also send a message directly to a raw token:

```ruby
ExampleMessage.new(...).send_to token: 'token123'
```

or to a topic:

```ruby
ExampleMessage.new(...).send_to topic: 'my-topic'
```

## Sending a test push

Maia comes with a built-in message to use to test your configuration out:

```ruby
Maia::Poke.new.send_to user
```
