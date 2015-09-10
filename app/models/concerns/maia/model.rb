module Maia
  module Model
    extend ActiveSupport::Concern

    included do
      has_many :devices, class_name: 'Maia::Device', as: :pushable
    end
  end
end
