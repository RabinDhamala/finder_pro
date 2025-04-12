# frozen_string_literal: true

module FinderPro
  module Models
    class Client
      attr_reader :id, :full_name, :email

      def initialize(id:, full_name:, email:)
        @id = id
        @full_name = full_name
        @email = email
      end

      def to_h
        {
          id: id,
          full_name: full_name,
          email: email,
        }
      end

      def self.valid_data?(data)
        data[:id].is_a?(Integer) &&
          data[:full_name].to_s.strip != '' &&
          data[:email].to_s.match?(/\A[^@\s]+@[^@\s]+\z/)
      end
    end
  end
end
