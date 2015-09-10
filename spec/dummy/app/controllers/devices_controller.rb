class DevicesController < ApplicationController
  respond_to :json

  before_action do
    @_current_user = User.find_by(email: 'test@testerson.com')
  end

  include Maia::Controller

  def current_user
    @_current_user
  end
end
