class TestMessage < Maia::Message
  def initialize(sound: 'default', badge: nil, priority: nil, content_available: false)
    @sound = sound
    @badge = badge
    @content_available = content_available
    @priority = priority
  end

  def alert
    'This is an alert'
  end

  def badge
    @badge
  end

  def sound
    @sound
  end

  def content_available?
    @content_available
  end

  def priority
    @priority || super
  end

  def other
    { data: 123 }
  end
end
