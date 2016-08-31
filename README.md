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

## Device Management

When GCM responds with an invalid or unregistered device token, the device record will be destroyed from the database.

When GCM responds with a canonical ID, the device record will be updated so that it's `token` field will be equal to the canonical ID given by GCM.

## Device Expiration

Devices will expire after 14 days. This is to ensure user's who sell or otherwise give away their device will not be tied to that device forever. Each
time a POST to Devices is received, the token expiration will be refreshed.

## Defining Messages

Maia provides a `Maia::Message` class that provides an interface for defining push messages and sending them. To define a message, override `Maia::Message` with
the data you need:

For example:

```ruby
class ExampleMessage < Maia::Message
  # Required
  def title
    'Something happened!'
  end

  # Required
  # Body of the message on Android, alert on iOS
  def body
    'Something very important has happened, check it out!'
  end

  # Determines the icon to load on Android phones
  def icon
    'icn_maia'
  end

  # Will use 'default' by default. Overriding to nil will prevent sound
  def sound
    'default'
  end

  # Badge to use on iOS
  def badge
    1
  end

  # #RRGGBB formatted color to use for the Android notification icon
  def color
    '#ffffff'
  end

  # click_action on Android, category on iOS
  def action
    'SOMETHING_HAPPENED'
  end

  # First argument title_loc_key, remaining arguments are title_loc_args
  # Translates to title-loc-key and title-loc-args on iOS
  def title_i18n
    ['SOMETHING_HAPPENED', 'First argument', 'Second argument']
  end

  # First argument body_loc_key, remaining arguments are body_loc_args
  # Translates to body-loc-key and body-loc-args on iOS
  def body_i18n
    ['SOMETHING_HAPPENED', 'First argument', 'Second argument']
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
  def content_available?
    false
  end

  # Override to true in order to send a dry run push. This can help debug any device errors without actually sending a push message
  def dry_run?
    false
  end
end
```

Will generate the following GCM payload (see [this table](https://developers.google.com/cloud-messaging/http-server-ref#table1) for parameter details):

```json
{
  "priority": "normal",
  "dry_run": false,
  "content_available": false,
  "data": {
    "foo": "bar"
  },
  "notification": {
    "title": "Something happened!",
    "body": "'Something very important has happened, check it out!'",
    "icon": "icn_maia",
    "sound": "default",
    "badge": 1,
    "color": "#ffffff",
    "click_action": "SOMETHING_HAPPENED",
    "body_loc_key": "SOMETHING_HAPPENED",
    "body_loc_args": ["Argument 1", "Argument 2"],
    "title_loc_key": "SOMETHING_HAPPENED",
    "title_loc_args": ["Argument 1", "Argument 2"]
  },
  "registration_ids": ["<TOKEN1>", "<TOKEN2>"]
}
```

`Maia::Message` does not define a constructor so you can construct your message however you want.

## Omitting the `notification`

Some applications may want to handle the notification from within, instead of deferring to the OS. To omit the notification hash from the payload,
override `notify?` with a falsy value. `notify?` accepts the platform as an argument (`:ios`, `:android`, or `:unknown`):

```ruby
class ExampleMessage < Maia::Message
  def notify?(platform)
    platform != :android
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

## Specifying job options (`wait`, `queue`, etc)

The `send_to` method passes it's last argument into [ActiveJob's `set` method](http://apidock.com/rails/ActiveJob/Core/ClassMethods/set), for example:

```ruby
ExampleMessage.new(...).send_to User.first, wait: 10.seconds, queue: :maia
```

## Sending a test push

Maia comes with a built-in message to use to test your configuration out:

```ruby
Maia::Poke.new.send_to user
```

Will send the title/body "Poke" to the device.
