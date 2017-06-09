module Maia
  module FCM
    class Notification
      attr_accessor :attributes

      def initialize(attributes = {})
        @attributes = attributes
      end

      def to_h
        @attributes
      end

      def ==(other)
        attributes == other.attributes
      end

      def method_missing(method_name, *args, &block)
        @attributes.fetch(method_name) { super }
      end

      def respond_to_missing?(method_name)
        @attributes.include? method_name
      end
    end
  end
end
