# frozen_string_literal: true

module FinderProCli
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
    end
  end
end
