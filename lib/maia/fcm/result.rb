module Maia
  module FCM
    class Result
      include ActiveModel::Model

      attr_accessor :message_id, :registration_id, :error
      attr_reader :token

      def initialize(attributes, token)
        super attributes
        @token = token
      end

      def success?
        message_id.present?
      end

      def fail?
        !success?
      end

      def canonical_id
        registration_id
      end

      def has_canonical_id?
        canonical_id.present?
      end
    end
  end
end
